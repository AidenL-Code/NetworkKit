//
//  MoyaRequestBuilder.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Foundation
import Moya

final class MoyaRequestBuilder {
    private let tokenProvider: AccessTokenProvider?

    init(tokenProvider: AccessTokenProvider?) {
        self.tokenProvider = tokenProvider
    }

    func build(
        endpoint: Endpoint,
        done: @escaping MoyaProvider<MoyaTargetAdapter>.RequestResultClosure
    ) {
        do {
            var request = try endpoint.urlRequest()

            _Concurrency.Task {
                if let token = await tokenProvider?.accessToken(), !token.isEmpty {
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }

                done(.success(request))
            }
        } catch {
            done(.failure(MoyaError.underlying(error, nil)))
        }
    }
}
