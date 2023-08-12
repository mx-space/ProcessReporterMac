//
//  ActiveApplicationObserver.swift
//  ProcessReporter
//
//  Created by Innei on 2023/7/9.
//

import Cocoa
import SwiftJotai

class ActiveApplicationObserver {
    private var observer: NSObjectProtocol?

    public static let shared = ActiveApplicationObserver()

    func observe(
        _ callback: @escaping ((String) -> Void)
    ) {
        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: nil,
            using: { notification in
                if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                    let name = app.localizedName ?? "unknown"
                    callback(name)
                }
            })
    }

    func dispose() {
        guard observer != nil else { return }
        NSWorkspace.shared.notificationCenter.removeObserver(observer)
    }
}
