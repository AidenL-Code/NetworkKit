//
//  NetworkResponse.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Foundation

public struct NetworkResponse {
    public let statusCode: Int
    public let data: Data
    public let headers: [AnyHashable: Any]

    public init(statusCode: Int, data: Data, headers: [AnyHashable: Any]) {
        self.statusCode = statusCode
        self.data = data
        self.headers = headers
    }
}

