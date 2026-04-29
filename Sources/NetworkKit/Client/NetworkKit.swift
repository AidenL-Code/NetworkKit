//
//  NetworkKit.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Foundation

public enum NetworkKit {
    private static var client: NetworkClient = NetworkClientFactory.makeDefault()

    public static var shared: NetworkClient {
        client
    }

    public static func configure(
        baseURLProvider: BaseURLProvider? = nil,
        tokenProvider: AccessTokenProvider? = nil,
        unauthorizedHandler: UnauthorizedHandler? = nil,
        timeout: NetworkTimeoutConfiguration = .default,
        plugins: [NetworkPlugin] = [],
        decoder: JSONDecoder = JSONDecoder()
    ) {
        client = NetworkClientFactory.makeDefault(
            baseURLProvider: baseURLProvider,
            tokenProvider: tokenProvider,
            unauthorizedHandler: unauthorizedHandler,
            timeout: timeout,
            plugins: plugins,
            decoder: decoder
        )
    }

    public static func use(_ client: NetworkClient) {
        self.client = client
    }
}
