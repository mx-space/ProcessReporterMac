//
//  MenuBarView.swift
//  ProcessReporter
//
//  Created by Innei on 2023/6/24.
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        Group {
            Button(store.isReporting ? "Pause" : "Start") {
                if store.isReporting {
                    Reporter.shared.stopReporting()
                } else {
                    Reporter.shared.startReporting()
                }
            }
            .keyboardShortcut("S")

            Button("Setting") {
                Reporter.shared.setting()
            }
            .keyboardShortcut(".", modifiers: .command)

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)

            }.keyboardShortcut("q")
        }
    }
}

struct MenuBarView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarView()
    }
}
