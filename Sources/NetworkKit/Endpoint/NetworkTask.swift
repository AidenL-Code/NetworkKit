//
//  NetworkTask.swift
//  NetworkKit
//
//  Created by Aiden on 2026/4/29.
//

import Foundation

public enum NetworkTask {
    case plain
    case query([String: Any])
    case json([String: Any])
    case form([String: Any])
    case upload(data: Data, name: String, fileName: String, mimeType: String)
    case download(destination: URL)
}

