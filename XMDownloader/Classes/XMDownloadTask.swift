//
//  XMDownloadTask.swift
//  XMDownloader
//
//  Created by apple on 2024/8/26.
//

import Foundation

public class XMDownloadTask {
    
    public var url: URL
    
    public var downloadTask: URLSessionDownloadTask
    
    public var cache: XMCache
    
    public var progressHandlers: [XMDownloader.ProgressHandler] = []
    
    public var completionHandlers: [XMDownloader.CompletionHandler] = []
    
    init(url: URL, downloadTask: URLSessionDownloadTask, cache: XMCache) {
        self.url = url
        self.downloadTask = downloadTask
        self.cache = cache
    }
    
    public func resume() {
        self.downloadTask.resume()
    }
    
    public func suspend() {
        self.downloadTask.suspend()
    }
    
    public func cancel() {
        self.downloadTask.cancel()
    }
    
    public func saveFile(from local: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let fileName = self.url.lastPathComponent
        self.cache.saveFile(with: fileName, from: local, completion: completion)
    }
    
    func appendProgressHandler(_ handler: @escaping XMDownloader.ProgressHandler) {
        self.progressHandlers.append(handler)
    }
    
    func appendCompletionHandler(_ handler: @escaping XMDownloader.CompletionHandler) {
        self.completionHandlers.append(handler)
    }
    
    func handleProgress(bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        for progressHandler in progressHandlers {
            progressHandler(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, progress)
        }
    }
    
    func handleCompletion(with result: Result<String, XMDownloadError>) {
        for completionHandler in completionHandlers {
            completionHandler(result)
        }
    }
}
