//
//  SlackIntegrationView.swift
//  ProcessReporter
//
//  Created by Innei on 2023/8/12.
//

import Combine
import SwiftJotai
import SwiftUI

struct SlackIntegrationView: View {
    @State private var localToken: String
    @State private var localEmoji: String
    @State private var localFormatter: String

    var singleEmoji: Binding<String> {
        Binding(
            get: { localEmoji },
            set: { newValue in
                localEmoji = newValue.count > 1 ? String(newValue.first!) : newValue
            }
        )
    }

    @StateObject private var slackEnabled = AtomValue(Atoms.slackReportEnabledAtom)
    @StateObject private var slackApiToken = AtomValue(Atoms.slackApiTokenAtom)
    @StateObject private var slackEmoji = AtomValue(Atoms.slackStatusEmojiAtom)
    @StateObject private var slackFormatter = AtomValue(Atoms.slackStatusTextFormatterAtom)

    init() {
        _localToken = State(initialValue: JotaiStore.shared.get(Atoms.slackApiTokenAtom))
        _localEmoji = State(initialValue: JotaiStore.shared.get(Atoms.slackStatusEmojiAtom))
        _localFormatter = State(initialValue: JotaiStore.shared.get(Atoms.slackStatusTextFormatterAtom))
    }

    var body: some View {
        Form {
            Toggle("Enable", isOn: slackEnabled.binding)

            Divider()

            SecureField("API Token", text: $localToken, onCommit: {
                slackApiToken.value = localToken
            })

            Divider()

            TextField("Status Emoji", text: singleEmoji, onCommit: {
                slackEmoji.value = localEmoji
            })
            TextField("Status Formatter", text: $localFormatter, onCommit: {
                slackFormatter.value = localFormatter
            })
        }
        .onAppear {
            self.setupNotifications()
        }
        .onDisappear {
            debugPrint("disapper")
            self.saveChange()
        }
    }

    func saveChange() {
        slackApiToken.value = localToken
        slackEmoji.value = localEmoji
        slackFormatter.value = localFormatter
    }

    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: nil, queue: .main) { _ in

            self.saveChange()
        }
    }
}
