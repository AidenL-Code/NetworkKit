//
//  NetworkKitTests.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Foundation
import Moya
import XCTest
@testable import NetworkKit

final class NetworkKitTests: XCTestCase {
    func testSharedClientExists() {
        XCTAssertTrue(NetworkKit.shared is NetworkClient)
    }

    func testUseReplacesSharedClient() {
        let mockClient = MockNetworkClient()
        NetworkKit.use(mockClient)

        XCTAssertTrue(NetworkKit.shared is MockNetworkClient)

        NetworkKit.configure()
    }

    func testConfigureRebuildsSharedClient() {
        NetworkKit.use(MockNetworkClient())
        XCTAssertTrue(NetworkKit.shared is MockNetworkClient)

        NetworkKit.configure(
            tokenProvider: StubTokenProvider(token: "token-1"),
            unauthorizedHandler: StubUnauthorizedHandler()
        )

        XCTAssertFalse(NetworkKit.shared is MockNetworkClient)

        NetworkKit.configure()
    }

    func testUnauthorizedHandlerIsCalledWhenResponseIs401() async throws {
        let handler = StubUnauthorizedHandler()
        let provider = MoyaProvider<MoyaTargetAdapter>(
            endpointClosure: { target in
                Endpoint(
                    url: target.resolvedURL.absoluteString,
                    sampleResponseClosure: { .networkResponse(401, Data()) },
                    method: target.method,
                    task: target.task,
                    httpHeaderFields: target.headers
                )
            },
            stubClosure: MoyaProvider.immediatelyStub
        )
        let client = MoyaNetworkClient(provider: provider, unauthorizedHandler: handler)
        let endpoint = APIEndpoint(
            url: URL(string: "https://api.example.com/secure")!,
            method: .get
        )

        do {
            _ = try await client.request(endpoint)
            XCTFail("Expected unauthorized error")
        } catch NetworkError.unauthorized {
            XCTAssertEqual(handler.callCount, 1)
        } catch {
            XCTFail("Expected unauthorized error, got \(error)")
        }
    }

    func testPathEndpointWithoutBaseURLProviderThrowsInvalidURL() async throws {
        let endpoint = APIEndpoint(path: "/devices", method: .get)

        do {
            _ = try await NetworkKit.shared.request(endpoint)
            XCTFail("Expected invalidURL error")
        } catch NetworkError.invalidURL {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Expected invalidURL error, got \(error)")
        }
    }

    func testMapsTimedOutURLError() async throws {
        let client = makeClientReturning(error: URLError(.timedOut))
        let endpoint = APIEndpoint(url: URL(string: "https://api.example.com/devices")!)

        do {
            _ = try await client.request(endpoint)
            XCTFail("Expected timeout error")
        } catch NetworkError.timeout {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Expected timeout error, got \(error)")
        }
    }

    func testMapsNoInternetURLError() async throws {
        let client = makeClientReturning(error: URLError(.notConnectedToInternet))
        let endpoint = APIEndpoint(url: URL(string: "https://api.example.com/devices")!)

        do {
            _ = try await client.request(endpoint)
            XCTFail("Expected noInternet error")
        } catch NetworkError.noInternet {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Expected noInternet error, got \(error)")
        }
    }

    func testMapsSecureConnectionFailedURLError() async throws {
        let client = makeClientReturning(error: URLError(.secureConnectionFailed))
        let endpoint = APIEndpoint(url: URL(string: "https://api.example.com/devices")!)

        do {
            _ = try await client.request(endpoint)
            XCTFail("Expected secureConnectionFailed error")
        } catch NetworkError.secureConnectionFailed {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Expected secureConnectionFailed error, got \(error)")
        }
    }

    private func makeClientReturning(error: Error) -> MoyaNetworkClient {
        let provider = MoyaProvider<MoyaTargetAdapter>(
            endpointClosure: { target in
                Endpoint(
                    url: target.resolvedURL.absoluteString,
                    sampleResponseClosure: { .networkError(error as NSError) },
                    method: target.method,
                    task: target.task,
                    httpHeaderFields: target.headers
                )
            },
            stubClosure: MoyaProvider.immediatelyStub
        )

        return MoyaNetworkClient(provider: provider)
    }
}

private final class MockNetworkClient: NetworkClient {
    func request<T: Decodable>(_ endpoint: APIEndpoint, as type: T.Type) async throws -> T {
        throw NetworkError.emptyResponse
    }

    func request(_ endpoint: APIEndpoint) async throws -> NetworkResponse {
        throw NetworkError.emptyResponse
    }
}

private final class StubTokenProvider: AccessTokenProvider {
    private let token: String?

    init(token: String?) {
        self.token = token
    }

    func accessToken() async -> String? {
        token
    }
}

private final class StubUnauthorizedHandler: UnauthorizedHandler {
    private(set) var callCount = 0

    func didReceiveUnauthorized() {
        callCount += 1
    }
}
