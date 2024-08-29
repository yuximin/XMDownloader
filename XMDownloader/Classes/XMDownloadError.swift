//
//  XMDownloadError.swift
//  XMDownloader
//
//  Created by apple on 2024/8/26.
//

import Foundation

public enum XMDownloadError: Error {
    case invalidURL(URLConvertible)
    case downloadFailure(Error)
    case cacheFailure(Error)
}

extension XMDownloadError {
    public var localizedDescription: String {
        switch self {
        case .invalidURL(let url):
            return "无效链接:\(url)"
        case .downloadFailure(let error):
            return "文件下载失败：\(error.localizedDescription)"
        case .cacheFailure(let error):
            return "文件保存失败：\(error.localizedDescription)"
        }
    }
}
