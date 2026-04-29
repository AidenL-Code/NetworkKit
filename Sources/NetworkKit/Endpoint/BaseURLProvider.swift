//
//  BaseURLProvider.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Foundation

public struct BaseURLKey: Hashable, ExpressibleByStringLiteral {
    public static let `default`: BaseURLKey = "default"
    public static let api: BaseURLKey = "api"
    public static let upload: BaseURLKey = "upload"
    public static let device: BaseURLKey = "device"
    public static let billing: BaseURLKey = "billing"

    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = value
    }
}

public protocol BaseURLProvider {
    func baseURL(for key: BaseURLKey) -> URL
}
