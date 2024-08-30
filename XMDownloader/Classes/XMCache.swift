//
//  XMCache.swift
//  XMDownloader
//
//  Created by apple on 2024/8/23.
//

import Foundation

public class XMCache {
    
    public static let `default` = XMCache()
    
    private let destDirectoryPath: String
    
    init(destDirectoryPath: String? = nil) {
        if let destDirectoryPath {
            self.destDirectoryPath = destDirectoryPath
        } else {
            let cacheDirectoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
            self.destDirectoryPath = cacheDirectoryPath + "/xm.downloader"
        }
    }
    
    private func getTargetFilePath(for filename: String) -> String {
        if self.destDirectoryPath.last == "/" {
            return self.destDirectoryPath + filename
        }
        return self.destDirectoryPath + "/" + filename
    }
    
    public func saveFile(with name: String, from local: URL, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let fileManager = FileManager.default
            
            if !fileManager.fileExists(atPath: self.destDirectoryPath) {
                try fileManager.createDirectory(atPath: self.destDirectoryPath, withIntermediateDirectories: true)
            }
            
            let targetFilePath = self.getTargetFilePath(for: name)
            let targetFileURL = URL(fileURLWithPath: targetFilePath)
            
            try fileManager.moveItem(at: local, to: targetFileURL)
            completion(.success(targetFilePath))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func isExist(for url: URLConvertible) -> Bool {
        guard let validURL = try? url.asURL(),
              let target = self.cacheFilePath(for: validURL) else { return false }
        
        return FileManager.default.fileExists(atPath: target)
    }
    
    public func cacheFilePath(for url: URLConvertible) -> String? {
        guard let validURL = try? url.asURL() else { return nil }
        
        let lastPathComponent = validURL.lastPathComponent
        let targetFilePath = self.getTargetFilePath(for: lastPathComponent)
        return targetFilePath
    }
}
