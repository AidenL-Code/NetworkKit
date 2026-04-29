//
//  NetworkPlugin.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Foundation

public protocol NetworkPlugin {
    func willSend(_ request: URLRequest)
    func didReceive(_ response: NetworkResponse)
    func didFail(_ error: NetworkError)
}

public extension NetworkPlugin {
    func willSend(_ request: URLRequest) {}
    func didReceive(_ response: NetworkResponse) {}
    func didFail(_ error: NetworkError) {}
}

