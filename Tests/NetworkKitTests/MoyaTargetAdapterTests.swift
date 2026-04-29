//
//  MoyaTargetAdapterTests.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Moya
import XCTest
@testable import NetworkKit

final class MoyaTargetAdapterTests: XCTestCase {
    func testAdapterSplitsBaseURLAndPath() throws {
        let endpoint = APIEndpoint(
            url: try XCTUnwrap(URL(string: "https://api.example.com/v1/devices?type=bike")),
            method: .get,
            headers: ["Accept": "application/json"],
            task: .plain
        )

        let target = MoyaTargetAdapter(endpoint: endpoint, resolvedURL: try XCTUnwrap(endpoint.url))

        XCTAssertEqual(target.baseURL.absoluteString, "https://api.example.com")
        XCTAssertEqual(target.path, "/v1/devices?type=bike")
        XCTAssertEqual(target.method, .get)
        XCTAssertEqual(target.headers?["Accept"], "application/json")
    }

    func testAdapterCreatesJsonTask() throws {
        let endpoint = APIEndpoint(
            url: try XCTUnwrap(URL(string: "https://api.example.com/login")),
            method: .post,
            task: .json(["phone": "123"])
        )

        let target = MoyaTargetAdapter(endpoint: endpoint, resolvedURL: try XCTUnwrap(endpoint.url))

        guard case let .requestParameters(parameters, encoding) = target.task else {
            XCTFail("Expected requestParameters task")
            return
        }

        XCTAssertEqual(parameters["phone"] as? String, "123")
        XCTAssertTrue(encoding is JSONEncoding)
    }

    func testAdapterCreatesQueryTask() throws {
        let endpoint = APIEndpoint(
            url: try XCTUnwrap(URL(string: "https://api.example.com/devices")),
            method: .get,
            task: .query(["page": 1])
        )

        let target = MoyaTargetAdapter(endpoint: endpoint, resolvedURL: try XCTUnwrap(endpoint.url))

        guard case let .requestParameters(parameters, encoding) = target.task else {
            XCTFail("Expected requestParameters task")
            return
        }

        XCTAssertEqual(parameters["page"] as? Int, 1)
        XCTAssertTrue(encoding is URLEncoding)
    }

    func testPathEndpointResolvesURLWithBaseURLProvider() throws {
        let provider = StubBaseURLProvider(
            urls: [.default: try XCTUnwrap(URL(string: "https://api.example.com/v1"))]
        )
        let endpoint = APIEndpoint(
            path: "/devices",
            method: .get
        )

        let resolvedURL = try XCTUnwrap(endpoint.resolvedURL(baseURLProvider: provider))
        let target = MoyaTargetAdapter(endpoint: endpoint, resolvedURL: resolvedURL)

        XCTAssertEqual(resolvedURL.absoluteString, "https://api.example.com/v1/devices")
        XCTAssertEqual(target.baseURL.absoluteString, "https://api.example.com")
        XCTAssertEqual(target.path, "/v1/devices")
    }

    func testPathEndpointResolvesURLWithAppBaseURLProvider() throws {
        let provider = AppBaseURLProvider()
        let endpoint = APIEndpoint(
            path: "/devices",
            baseURLKey: .device,
            method: .get
        )

        let resolvedURL = try XCTUnwrap(endpoint.resolvedURL(baseURLProvider: provider))
        let target = MoyaTargetAdapter(endpoint: endpoint, resolvedURL: resolvedURL)

        XCTAssertEqual(resolvedURL.absoluteString, "https://device.example.com/v1/devices")
        XCTAssertEqual(target.baseURL.absoluteString, "https://device.example.com")
        XCTAssertEqual(target.path, "/v1/devices")
    }
}

private struct StubBaseURLProvider: BaseURLProvider {
    let urls: [BaseURLKey: URL]

    func baseURL(for key: BaseURLKey) -> URL {
        urls[key]!
    }
}

private final class AppBaseURLProvider: BaseURLProvider {
    func baseURL(for key: BaseURLKey) -> URL {
        switch key {
        case .api:
            return AppConfig.shared.current.apiBaseURL
        case .upload:
            return AppConfig.shared.current.uploadBaseURL
        case .device:
            return AppConfig.shared.current.deviceBaseURL
        case .billing:
            return AppConfig.shared.current.billingBaseURL
        default:
            return AppConfig.shared.current.apiBaseURL
        }
    }
}

private final class AppConfig {
    static let shared = AppConfig()

    let current = AppEnvironment(
        apiBaseURL: URL(string: "https://api.example.com/v1")!,
        uploadBaseURL: URL(string: "https://upload.example.com/v1")!,
        deviceBaseURL: URL(string: "https://device.example.com/v1")!,
        billingBaseURL: URL(string: "https://billing.example.com/v1")!
    )
}

private struct AppEnvironment {
    let apiBaseURL: URL
    let uploadBaseURL: URL
    let deviceBaseURL: URL
    let billingBaseURL: URL
}
