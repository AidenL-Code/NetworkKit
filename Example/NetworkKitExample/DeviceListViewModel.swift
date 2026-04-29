//
//  DeviceListViewModel.swift
//  NetworkKitExample
//
//  Created by Aiden on 2026/4/29.
//

import Foundation
import NetworkKit

@MainActor
final class DeviceListViewModel: ObservableObject {
    @Published private(set) var devices: [DeviceDTO] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    private var hasLoaded = false

    func loadDevices() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        isLoading = true
        errorMessage = nil

        do {
            devices = try await NetworkKit.shared.request(DeviceAPI.list, as: [DeviceDTO].self)
        } catch {
            errorMessage = String(describing: error)
        }

        isLoading = false
    }
}
