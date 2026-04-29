//
//  UnauthorizedHandler.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Foundation

public protocol UnauthorizedHandler: AnyObject {
    func didReceiveUnauthorized()
}

