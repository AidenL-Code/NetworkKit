//
//  MoyaNetworkClient.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Foundation
import Alamofire
import Moya

final class MoyaNetworkClient: NetworkClient {
    private let provider: MoyaProvider<MoyaTargetAdapter>
    private let baseURLProvider: BaseURLProvider?
    private let unauthorizedHandler: UnauthorizedHandler?
    private let decoder: JSONDecoder

    init(
        baseURLProvider: BaseURLProvider? = nil,
        tokenProvider: AccessTokenProvider? = nil,
        unauthorizedHandler: UnauthorizedHandler? = nil,
        timeout: NetworkTimeoutConfiguration = .default,
        plugins: [NetworkPlugin] = [],
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURLProvider = baseURLProvider
        self.unauthorizedHandler = unauthorizedHandler
        self.decoder = decoder

        let moyaPlugins = plugins.map(MoyaPluginAdapter.init)
        self.provider = MoyaProvider<MoyaTargetAdapter>(
            requestClosure: MoyaRequestBuilder(tokenProvider: tokenProvider).build,
            session: Self.makeSession(timeout: timeout),
            plugins: moyaPlugins
        )
    }

    init(
        provider: MoyaProvider<MoyaTargetAdapter>,
        baseURLProvider: BaseURLProvider? = nil,
        unauthorizedHandler: UnauthorizedHandler? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.provider = provider
        self.baseURLProvider = baseURLProvider
        self.unauthorizedHandler = unauthorizedHandler
        self.decoder = decoder
    }

    public func request<T: Decodable>(_ endpoint: APIEndpoint, as type: T.Type) async throws -> T {
        let response: NetworkResponse = try await request(endpoint)

        do {
            return try decoder.decode(T.self, from: response.data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }

    public func request(_ endpoint: APIEndpoint) async throws -> NetworkResponse {
        guard let resolvedURL = endpoint.resolvedURL(baseURLProvider: baseURLProvider) else {
            throw NetworkError.invalidURL
        }

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<NetworkResponse, Error>) in
            provider.request(MoyaTargetAdapter(endpoint: endpoint, resolvedURL: resolvedURL)) { [weak self] result in
                switch result {
                case let .success(response):
                    if response.statusCode == 401 {
                        self?.unauthorizedHandler?.didReceiveUnauthorized()
                        continuation.resume(throwing: NetworkError.unauthorized)
                        return
                    }

                    guard (200..<300).contains(response.statusCode) else {
                        continuation.resume(
                            throwing: NetworkError.server(statusCode: response.statusCode, data: response.data)
                        )
                        return
                    }

                    continuation.resume(
                        returning: NetworkResponse(
                            statusCode: response.statusCode,
                            data: response.data,
                            headers: response.response?.allHeaderFields ?? [:]
                        )
                    )

                case let .failure(error):
                    continuation.resume(throwing: Self.mapError(error))
                }
            }
        }
    }

    private static func mapError(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        }

        if let moyaError = error as? MoyaError {
            switch moyaError {
            case let .underlying(error, _):
                return mapError(error)
            default:
                return .underlying(moyaError)
            }
        }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet,
                 .networkConnectionLost,
                 .cannotFindHost,
                 .cannotConnectToHost:
                return .noInternet
            case .timedOut:
                return .timeout
            case .secureConnectionFailed,
                 .serverCertificateHasBadDate,
                 .serverCertificateUntrusted,
                 .serverCertificateHasUnknownRoot,
                 .serverCertificateNotYetValid,
                 .clientCertificateRejected,
                 .clientCertificateRequired:
                return .secureConnectionFailed
            default:
                return .underlying(urlError)
            }
        }

        return .underlying(error)
    }

    private static func makeSession(timeout: NetworkTimeoutConfiguration) -> Session {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout.request
        configuration.timeoutIntervalForResource = timeout.resource
        return Session(configuration: configuration)
    }
}
