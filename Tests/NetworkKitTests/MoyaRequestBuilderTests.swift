//
//  MoyaRequestBuilderTests.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Moya
import XCTest
@testable import NetworkKit

final class MoyaRequestBuilderTests: XCTestCase {
    func testRequestBuilderAddsLatestToken() async throws {
        let tokenProvider = StubTokenProvider(token: "token-1")
        let builder = MoyaRequestBuilder(tokenProvider: tokenProvider)
        let endpoint = Endpoint(
            url: "https://api.example.com/devices",
            sampleResponseClosure: { .networkResponse(200, Data()) },
            method: .get,
            task: .requestPlain,
            httpHeaderFields: nil
        )

        let request = try await buildRequest(builder: builder, endpoint: endpoint)

        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token-1")
    }

    func testRequestBuilderUsesUpdatedToken() async throws {
        let tokenProvider = StubTokenProvider(token: "token-1")
        let builder = MoyaRequestBuilder(tokenProvider: tokenProvider)
        let endpoint = Endpoint(
            url: "https://api.example.com/devices",
            sampleResponseClosure: { .networkResponse(200, Data()) },
            method: .get,
            task: .requestPlain,
            httpHeaderFields: nil
        )

        tokenProvider.token = "token-2"
        let request = try await buildRequest(builder: builder, endpoint: endpoint)

        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token-2")
    }

    private func buildRequest(builder: MoyaRequestBuilder, endpoint: Endpoint) async throws -> URLRequest {
        try await withCheckedThrowingContinuation { continuation in
            builder.build(endpoint: endpoint) { result in
                switch result {
                case let .success(request):
                    continuation.resume(returning: request)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

private final class StubTokenProvider: AccessTokenProvider {
    var token: String?

    init(token: String?) {
        self.token = token
    }

    func accessToken() async -> String? {
        token
    }
}

