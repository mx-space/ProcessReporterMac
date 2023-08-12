//
//  ProcessReporterApp.swift
//  ProcessReporter
//
//  Created by Innei on 2023/6/24.
//
import Combine
import SwiftJotai
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
    @StateObject var isReporting = AtomValue(Atoms.isReportingAtom)
    @StateObject var networkOnline = AtomValue(Atoms.networkOnlineAtom)

    var reporter = Reporter.shared

    init() {
        NotificationManager.requestNotificationAuthorization()

        if JotaiStore.shared.get(Atoms.isReportingAtom) {
            reporter.startReporting()
        } else {
            Application.openSetting()
        }

        ActiveApplicationObserver.shared.observe { name in
            JotaiStore.shared.set(Atoms.currentFrontAppAtom, value: name)
        }
    }

    var menuIcon: String {
        return isReporting.value ?
            networkOnline.value ? "arrow.clockwise.icloud" : "xmark.icloud"
            : "cloud"
    }

    var body: some Scene {
        Settings {
            SettingView().environmentObject(store)
        }

        MenuBarExtra("sync", systemImage: menuIcon) {
            MenuBarView().environmentObject(store)
        }
//        .menuBarExtraStyle(.window)
    }
}
