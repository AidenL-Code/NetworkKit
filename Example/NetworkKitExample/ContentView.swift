//
//  ContentView.swift
//  NetworkKitExample
//
//  Created by Aiden on 2026/4/29.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DeviceListViewModel()

    var body: some View {
        NavigationView {
            List {
                if viewModel.isLoading {
                    ProgressView("Loading devices...")
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }

                ForEach(viewModel.devices.prefix(20)) { device in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("#\(device.id)")
                            .font(.caption)

                        Text(device.title)
                            .font(.body)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("NetworkKit")
            .onAppear {
                Task {
                    await viewModel.loadDevices()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
