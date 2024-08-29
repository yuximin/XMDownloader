//
//  URLConvertible.swift
//  XMDownloader
//
//  Created by apple on 2024/8/29.
//

import Foundation

public protocol URLConvertible {

    func asURL() throws -> URL
}

extension String: URLConvertible {
    
    public func asURL() throws -> URL {
        guard let url = URL(string: self) else { throw XMDownloadError.invalidURL(self) }
        
        return url
    }
}

extension URL: URLConvertible {

    public func asURL() throws -> URL { return self }
}

extension URLComponents: URLConvertible {

    public func asURL() throws -> URL {
        guard let url = url else { throw XMDownloadError.invalidURL(self) }
        
        return url
    }
}
