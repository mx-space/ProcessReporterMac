//
//  StatusBarManager.swift
//  ProcessReporter
//
//  Created by Innei on 2023/7/8.
//

import Combine

class StatusBarManager: ObservableObject {
    private var cancellable: AnyCancellable?
    @Published var statusBarIcon: String = "cloud"

    init(store: Store) {
        cancellable = store.$isReporting.sink { [weak self] newValue in
            if newValue {
                self?.statusBarIcon = "arrow.clockwise.icloud"
            } else {
                self?.statusBarIcon = "cloud"
            }
        }
    }
}
