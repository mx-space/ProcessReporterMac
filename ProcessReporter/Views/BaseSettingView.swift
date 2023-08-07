//
//  BaseSettingView.swift
//  ProcessReporter
//
//  Created by Innei on 2023/7/16.
//

import SwiftJotai
import SwiftUI

struct BaseSettingView: View {
    @EnvironmentObject var store: Store

    @StateObject var isReporting = AtomValue(Atoms.isReportingAtom)

    var body: some View {
        Group {
            Toggle(isOn: isReporting.binding, label: {
                Text("Enable")
            })
            .keyboardShortcut("S")

            Button("Setting") {
                NSApplication.shared.activate(ignoringOtherApps: true)
                Application.openSetting()
            }
            .keyboardShortcut(".", modifiers: .command)
        }
    }
}

struct BaseSettingView_Previews: PreviewProvider {
    static var previews: some View {
        BaseSettingView()
    }
}
