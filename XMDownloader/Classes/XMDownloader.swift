//
//  XMDownloader.swift
//  XMDownloader
//
//  Created by apple on 2024/8/23.
//

import Foundation

public class XMDownloader: NSObject {
    
    public typealias ProgressHandler = (Int64, Int64, Int64, Double) -> Void
    public typealias CompletionHandler = (Result<String, XMDownloadError>) -> Void
    
    public static let shared = XMDownloader()
    
    private lazy var downloadSession: URLSession = {
        URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    
    private let operationQueue = DispatchQueue(label: "queue.xm.downloader.operation")
    
    private var downloadTaskMap: [String: XMDownloadTask] = [:]
    
    public func downloadFile(url: URLConvertible, cache: XMCache = .default, progressHandler: ProgressHandler? = nil, completionHandler: CompletionHandler? = nil) {
        do {
            let validURL = try url.asURL()
            
            operationQueue.async {
                if cache.isExist(for: validURL),
                   let targetFilePath = cache.cacheFilePath(for: validURL) {
                    completionHandler?(.success(targetFilePath))
                    return
                }
                
                if let task = self.downloadTaskMap[validURL.absoluteString] {
                    if let progressHandler {
                        task.appendProgressHandler(progressHandler)
                    }
                    if let completionHandler {
                        task.appendCompletionHandler(completionHandler)
                    }
                    return
                }
                
                let downloadTask = self.downloadSession.downloadTask(with: validURL)
                let task = XMDownloadTask(url: validURL, downloadTask: downloadTask, cache: cache)
                if let progressHandler {
                    task.appendProgressHandler(progressHandler)
                }
                if let completionHandler {
                    task.appendCompletionHandler(completionHandler)
                }
                task.resume()
                self.downloadTaskMap[validURL.absoluteString] = task
            }
        } catch {
            completionHandler?(.failure(.downloadFailure(error)))
        }
    }
    
    public func cancelDownloadFile(url: URLConvertible) {
        guard let validURL = try? url.asURL() else { return }
        let remotePath = validURL.absoluteString
        
        operationQueue.async {
            let task = self.downloadTaskMap[remotePath]
            task?.cancel()
        }
    }
}

// MARK: - URLSessionDelegate
extension XMDownloader: URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        operationQueue.async {
            guard let downloadTask = task as? URLSessionDownloadTask,
                  let task = self.downloadTaskMap.values.first(where: { $0.downloadTask == downloadTask }) else { return }
            
            if let error {
                task.handleCompletion(with: .failure(.downloadFailure(error)))
            }
            
            self.downloadTaskMap[task.url.absoluteString] = nil
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // 这里同步执行，是因为`location`指向的`tmp`文件在方法执行结束之后就会被清理。
        // 如果异步执行，文件已经被清理掉，无法完成缓存。
        operationQueue.sync {
            guard let task = self.downloadTaskMap.values.first(where: { $0.downloadTask == downloadTask }) else { return }
                
            task.saveFile(from: location) { [weak task] result in
                switch result {
                case .success(let filePath):
                    task?.handleCompletion(with: .success(filePath))
                case .failure(let error):
                    task?.handleCompletion(with: .failure(.cacheFailure(error)))
                }
            }
            self.downloadTaskMap[task.url.absoluteString] = nil
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        operationQueue.async {
            guard let task = self.downloadTaskMap.values.first(where: { $0.downloadTask == downloadTask }) else { return }
            
            task.handleProgress(bytesWritten: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
        }
    }
}
