//
//  NetworkKitExampleTests.swift
//  NetworkKitExample
//
//  Created by Aiden on 2026/4/29.
//

import NetworkKit
import XCTest

final class NetworkKitExampleTests: XCTestCase {
    func testCanCreateEndpointFromExampleApp() throws {
        let url = try XCTUnwrap(URL(string: "https://api.example.com/devices"))
        let endpoint = APIEndpoint(url: url, method: .get)

        XCTAssertEqual(endpoint.url, url)
    }
}

