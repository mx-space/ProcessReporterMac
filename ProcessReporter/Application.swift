//
//  Application.swift
//  ProcessReporter
//
//  Created by Innei on 2023/7/18.
//

import AppKit

enum Application {
    @MainActor static func openSelectedModal() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose one or more applications"
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = true
        openPanel.allowedContentTypes = [.application]
        openPanel.directoryURL = URL(fileURLWithPath: "/Applications", isDirectory: true)

        if openPanel.runModal() == NSApplication.ModalResponse.OK {
            let urls = openPanel.urls

            var appDisplayNames = [String]()
            for url in urls {
                let infoPlistURL = url.appendingPathComponent("Contents").appendingPathComponent("Info.plist")
                if let infoPlist = NSDictionary(contentsOf: infoPlistURL),
                   let appName = infoPlist["CFBundleDisplayName"] as? String {
                    print(appName)
                    appDisplayNames.append(appName)
                }
            }

            JotaiStore.shared.set(Atoms.excludedAppNamesAtom, value: appDisplayNames)
        }
    }
}
