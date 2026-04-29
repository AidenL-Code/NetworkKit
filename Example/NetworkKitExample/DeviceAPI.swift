//
//  DeviceAPI.swift
//  NetworkKitExample
//
//  Created by Aiden on 2026/4/29.
//

import Foundation
import NetworkKit

enum DeviceAPI {
    static var list: APIEndpoint {
        APIEndpoint(path: "/posts")
    }
}
