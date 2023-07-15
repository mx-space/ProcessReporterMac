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

    func bindingForReportType(_ reportType: ReportType) -> Binding<Bool> {
        Binding<Bool>(
            get: { store.reportType.contains(reportType) },
            set: { _ in store.reportType.addOrRemove(reportType) }
        )
    }

    var isMediaReport: Binding<Bool> { bindingForReportType(.media) }
    var isProcessReport: Binding<Bool> { bindingForReportType(.process) }

    var isAllReport: Binding<Bool> {
        Binding<Bool>(
            get: { store.reportType.contains(.media) && store.reportType.contains(.process) },
            set: {
                if $0 {
                    store.reportType = [.media, .process]
                } else {
                    store.reportType = []
                }
            }
        )
    }

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
                Reporter.shared.openSetting()
            }
            .keyboardShortcut(".", modifiers: .command)

            Divider()

            Toggle("Report Media", isOn: isMediaReport)
            Toggle("Report Process", isOn: isProcessReport)
            Toggle("Report All", isOn: isAllReport)

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
