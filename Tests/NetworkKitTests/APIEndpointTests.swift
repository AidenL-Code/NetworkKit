//
//  APIEndpointTests.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import XCTest
@testable import NetworkKit

final class APIEndpointTests: XCTestCase {
    func testTimeoutConfigurationUsesDefaultValues() {
        let timeout = NetworkTimeoutConfiguration.default

        XCTAssertEqual(timeout.request, 60)
        XCTAssertEqual(timeout.resource, 7 * 24 * 60 * 60)
    }

    func testTimeoutConfigurationStoresCustomValues() {
        let timeout = NetworkTimeoutConfiguration(request: 15, resource: 120)

        XCTAssertEqual(timeout.request, 15)
        XCTAssertEqual(timeout.resource, 120)
    }

    func testEndpointStoresRequestValues() throws {
        let url = try XCTUnwrap(URL(string: "https://api.example.com/devices"))
        let endpoint = APIEndpoint(
            url: url,
            method: .post,
            headers: ["X-Trace-ID": "trace-1"],
            task: .json(["name": "bike"])
        )

        XCTAssertEqual(endpoint.url, url)
        XCTAssertEqual(endpoint.method, .post)
        XCTAssertEqual(endpoint.headers["X-Trace-ID"], "trace-1")
    }
}
