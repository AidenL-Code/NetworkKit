//
//  DeviceDTO.swift
//  NetworkKitExample
//
//  Created by Aiden on 2026/4/29.
//

import Foundation

struct DeviceDTO: Decodable, Identifiable {
    let id: Int
    let title: String
}

