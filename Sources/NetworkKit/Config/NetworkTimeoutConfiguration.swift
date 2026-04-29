//
//  NetworkTimeoutConfiguration.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Foundation

public struct NetworkTimeoutConfiguration {
    public static let `default` = NetworkTimeoutConfiguration()

    public let request: TimeInterval
    public let resource: TimeInterval

    public init(
        request: TimeInterval = 60,
        resource: TimeInterval = 7 * 24 * 60 * 60
    ) {
        self.request = request
        self.resource = resource
    }
}
