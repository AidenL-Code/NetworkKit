//
//  MoyaTargetAdapter.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Foundation
import Moya

struct MoyaTargetAdapter: TargetType {
    let endpoint: APIEndpoint
    let resolvedURL: URL

    var baseURL: URL {
        guard var components = URLComponents(url: resolvedURL, resolvingAgainstBaseURL: false) else {
            return resolvedURL
        }

        components.path = ""
        components.query = nil

        return components.url ?? resolvedURL
    }

    var path: String {
        if let query = resolvedURL.query, !query.isEmpty {
            return "\(resolvedURL.path)?\(query)"
        }

        return resolvedURL.path
    }

    var method: Moya.Method {
        endpoint.method.moyaMethod
    }

    var task: Task {
        switch endpoint.task {
        case .plain:
            return .requestPlain
        case let .query(parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .json(parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case let .form(parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.httpBody)
        case let .upload(data, name, fileName, mimeType):
            let multipart = MultipartFormData(
                provider: .data(data),
                name: name,
                fileName: fileName,
                mimeType: mimeType
            )
            return .uploadMultipart([multipart])
        case let .download(destination):
            return .downloadDestination(downloadDestination(destination))
        }
    }

    var headers: [String: String]? {
        endpoint.headers
    }

    var sampleData: Data {
        Data()
    }

    private func downloadDestination(_ destination: URL) -> DownloadDestination {
        { _, _ in
            (destination, [.removePreviousFile, .createIntermediateDirectories])
        }
    }
}
