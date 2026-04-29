//
//  NetworkClient.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Foundation

public protocol NetworkClient {
    func request<T: Decodable>(_ endpoint: APIEndpoint, as type: T.Type) async throws -> T
    func request(_ endpoint: APIEndpoint) async throws -> NetworkResponse
}

