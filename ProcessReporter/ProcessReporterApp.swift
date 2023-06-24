//
//  ProcessReporterApp.swift
//  ProcessReporter
//
//  Created by Innei on 2023/6/24.
//
import SwiftUI

/// NOTE:
///  create a menu bar app:
///  delete WindowGroup
///  add MenuBarExtra
///  go to info.plist or target info tab and add key Application is agent (NSItem) set to YES

@main
struct swiftui_menu_barApp: App {
    @Environment(\.openWindow) var openWindow
    @StateObject var store = Store.shared

    var reporter = Reporter.shared
    init() {
        if reporter.isInited() {
            reporter.startReporting()
        } else {
            reporter.setting()
        }
    }

    var body: some Scene {
        Settings {
            SettingView().environmentObject(store)
        }

        MenuBarExtra("sync", systemImage: "arrow.clockwise.icloud") {
            MenuBarView().environmentObject(store)
        }
//        .menuBarExtraStyle(.window)
    }
}
