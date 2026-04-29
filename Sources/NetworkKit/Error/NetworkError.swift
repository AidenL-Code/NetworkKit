//
//  NetworkError.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Foundation

public enum NetworkError: Error {
    case invalidURL
    case unauthorized
    case server(statusCode: Int, data: Data?)
    case noInternet
    case timeout
    case secureConnectionFailed
    case decoding(Error)
    case underlying(Error)
    case emptyResponse
}
