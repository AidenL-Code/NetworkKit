//
//  APIEndpoint.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Foundation

public struct APIEndpoint {
    public let url: URL?
    public let path: String?
    public let baseURLKey: BaseURLKey
    public let method: HTTPMethod
    public let headers: [String: String]
    public let task: NetworkTask

    public init(
        url: URL,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        task: NetworkTask = .plain
    ) {
        self.url = url
        self.path = nil
        self.baseURLKey = .default
        self.method = method
        self.headers = headers
        self.task = task
    }

    public init(
        path: String,
        baseURLKey: BaseURLKey = .default,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        task: NetworkTask = .plain
    ) {
        self.url = nil
        self.path = path
        self.baseURLKey = baseURLKey
        self.method = method
        self.headers = headers
        self.task = task
    }
}

extension APIEndpoint {
    func resolvedURL(baseURLProvider: BaseURLProvider?) -> URL? {
        if let url {
            return url
        }

        guard let path, let baseURLProvider else {
            return nil
        }

        let baseURL = baseURLProvider.baseURL(for: baseURLKey)

        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            return baseURL.appendingPathComponent(path)
        }

        let normalizedBasePath = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let normalizedEndpointPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let joinedPath = [normalizedBasePath, normalizedEndpointPath]
            .filter { !$0.isEmpty }
            .joined(separator: "/")

        components.path = "/" + joinedPath
        return components.url
    }
}
