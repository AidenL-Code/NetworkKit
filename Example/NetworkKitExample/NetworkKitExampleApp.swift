//
//  NetworkKitExampleApp.swift
//  NetworkKitExample
//
//  Created by Aiden on 2026/4/29.
//

import NetworkKit
import SwiftUI

@main
struct NetworkKitExampleApp: App {
    init() {
        NetworkKit.configure(
            baseURLProvider: ExampleBaseURLProvider()
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

private struct ExampleBaseURLProvider: BaseURLProvider {
    func baseURL(for key: BaseURLKey) -> URL {
        switch key {
        case .default:
            return URL(string: "https://jsonplaceholder.typicode.com")!
        default:
            return URL(string: "https://jsonplaceholder.typicode.com")!
        }
    }
}
