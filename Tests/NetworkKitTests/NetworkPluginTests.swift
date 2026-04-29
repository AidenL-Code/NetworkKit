//
//  NetworkPluginTests.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import XCTest
@testable import NetworkKit

final class NetworkPluginTests: XCTestCase {
    func testDefaultPluginMethodsAreOptional() {
        let plugin = EmptyPlugin()
        let response = NetworkResponse(statusCode: 204, data: Data(), headers: [:])

        plugin.didReceive(response)
        plugin.didFail(.emptyResponse)

        XCTAssertTrue(true)
    }
}

private struct EmptyPlugin: NetworkPlugin {}

