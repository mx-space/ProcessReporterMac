//
//  ApiIntegrationView.swift
//  ProcessReporter
//
//  Created by Innei on 2023/8/12.
//

import SwiftJotai
import SwiftUI

struct ApiIntegrationView: View {
    @StateObject var apiKey = AtomValue(Atoms.apiKeyAtom)
    @StateObject var endpoint = AtomValue(Atoms.endpointAtom)
    @StateObject var enabled = AtomValue(Atoms.apiReportEnabledAtom)

    @State private var localApiKey: String
    @State private var localEndpoint: String

    init() {
        _localApiKey = State(initialValue: JotaiStore.shared.get(Atoms.apiKeyAtom))
        _localEndpoint = State(initialValue: JotaiStore.shared.get(Atoms.endpointAtom))
    }

    var body: some View {
        Form {
            Toggle("Enable", isOn: enabled.binding)

            Divider()
            SecureField("API Key", text: $localApiKey) {
                apiKey.value = localApiKey
            }
            TextField("Endpoint", text: $localEndpoint) {
                endpoint.value = localEndpoint
            }
        }
        .onAppear {
            self.setupNotifications()
        }
        .onDisappear {
            self.saveChange()
        }
    }

    func saveChange() {
        apiKey.value = localApiKey
        endpoint.value = localEndpoint
    }

    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: nil, queue: .main) { _ in

            self.saveChange()
        }
    }
}
