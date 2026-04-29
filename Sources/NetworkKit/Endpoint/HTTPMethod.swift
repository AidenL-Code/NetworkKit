//
//  HTTPMethod.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Foundation
import Moya

public enum HTTPMethod: Equatable {
    case get
    case post
    case put
    case patch
    case delete
}

extension HTTPMethod {
    var moyaMethod: Moya.Method {
        switch self {
        case .get:
            return .get
        case .post:
            return .post
        case .put:
            return .put
        case .patch:
            return .patch
        case .delete:
            return .delete
        }
    }
}
