//
//  ApiClient.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 06.11.2024.
//

import Combine
import Foundation

final class PollingManager {
    private(set) var shouldStartPolling = false

    private var cancellable: AnyCancellable?

    func startPolling() {
        guard !shouldStartPolling else { return }
        shouldStartPolling = true

        cancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                Task {
                    await ApiClient.shared.updateLobbyInfo()
                }
            }
    }

    func stopPolling() {
        guard shouldStartPolling else { return }
        shouldStartPolling = false

        cancellable?.cancel()
    }
}
