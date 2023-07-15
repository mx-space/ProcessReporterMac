//
//  MenuBarView.swift
//  ProcessReporter
//
//  Created by Innei on 2023/6/24.
//

import SwiftUI

let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

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
                NSApplication.shared.activate(ignoringOtherApps: true)
                Reporter.shared.setting()
            }
            .keyboardShortcut(".", modifiers: .command)

            Divider()
            #if DEBUG
                Text("IN DEBUG MODE")
            #endif

            Text(buildNumber!)

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
