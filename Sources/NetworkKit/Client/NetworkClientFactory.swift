//
//  NetworkClientFactory.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Foundation

public enum NetworkClientFactory {
    public static func makeDefault(
        baseURLProvider: BaseURLProvider? = nil,
        tokenProvider: AccessTokenProvider? = nil,
        unauthorizedHandler: UnauthorizedHandler? = nil,
        timeout: NetworkTimeoutConfiguration = .default,
        plugins: [NetworkPlugin] = [],
        decoder: JSONDecoder = JSONDecoder()
    ) -> NetworkClient {
        MoyaNetworkClient(
            baseURLProvider: baseURLProvider,
            tokenProvider: tokenProvider,
            unauthorizedHandler: unauthorizedHandler,
            timeout: timeout,
            plugins: plugins,
            decoder: decoder
        )
    }
}
