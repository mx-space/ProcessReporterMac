//
//  MenuBarView.swift
//  ProcessReporter
//
//  Created by Innei on 2023/6/24.
//

import LaunchAtLogin
import SwiftJotai
import SwiftUI

let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

struct MenuBarView: View {
    var body: some View {
        Group {
            BaseSettingView()

            Group {
                Divider()

                ReportTypeView()

                Divider()

                ReportInfoView()
                Divider()
            }

            LaunchAtLogin.Toggle {
                Text("Launch at login")
            }

            Divider()
            #if DEBUG
                Text("IN DEBUG MODE")
            #endif

            Group {
                Text(buildNumber!)

                Button("Quit") {
                    NSApplication.shared.terminate(nil)

                }.keyboardShortcut("q")
            }
        }
    }
}

struct MenuBarView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarView()
    }
}
