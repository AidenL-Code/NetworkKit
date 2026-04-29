//
//  AccessTokenProvider.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Foundation

public protocol AccessTokenProvider: AnyObject {
    func accessToken() async -> String?
}

