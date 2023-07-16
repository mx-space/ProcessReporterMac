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

    @StateObject var isReporting = AtomValue(isReportingAtom)

    var isReportBinding: Binding<Bool> {
        Binding<Bool>(get: {
            isReporting.value
        }) { value, _ in
            JotaiStore.shared.set(isReportingAtom, value: value)
        }
    }

    var body: some View {
        Group {
            Toggle(isOn: isReportBinding, label: {
                Text("Enable")
            })
            .keyboardShortcut("S")

            Button("Setting") {
                NSApplication.shared.activate(ignoringOtherApps: true)
                Reporter.shared.openSetting()
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
