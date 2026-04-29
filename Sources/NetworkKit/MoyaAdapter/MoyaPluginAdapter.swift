//
//  MoyaPluginAdapter.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Foundation
import Moya

final class MoyaPluginAdapter: PluginType {
    private let plugin: NetworkPlugin

    init(plugin: NetworkPlugin) {
        self.plugin = plugin
    }

    func willSend(_ request: RequestType, target: TargetType) {
        guard let urlRequest = request.request else { return }
        plugin.willSend(urlRequest)
    }

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case let .success(response):
            plugin.didReceive(
                NetworkResponse(
                    statusCode: response.statusCode,
                    data: response.data,
                    headers: response.response?.allHeaderFields ?? [:]
                )
            )
        case let .failure(error):
            plugin.didFail(.underlying(error))
        }
    }
}

