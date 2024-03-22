//
//  ActiveApplicationObserver.swift
//  ProcessReporter
//
//  Created by Innei on 2023/7/9.
//

import Cocoa
import SwiftJotai
import ApplicationServices

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
    
    
    public func getActiveApplicationInfo() -> ActiveApplicationInfo {
        
        guard let activeApp = NSWorkspace.shared.frontmostApplication else {
            
            debugPrint("no frontmost app")
            return ActiveApplicationInfo()
        }

        let appPID = activeApp.processIdentifier


        var appRef: AXUIElement?
        appRef = AXUIElementCreateApplication(appPID)

        var window: CFTypeRef?
        var title: String?


        let result = AXUIElementCopyAttributeValue(appRef!, kAXFocusedWindowAttribute as CFString, &window)
        if result == .success, let window = window {
            var windowTitle: CFTypeRef?
            AXUIElementCopyAttributeValue(window as! AXUIElement, kAXTitleAttribute as CFString, &windowTitle)
            title = windowTitle as? String
        }

        return ActiveApplicationInfo(title: title)
    }
}

struct ActiveApplicationInfo: Equatable {
    var title: String?
    
    static  func ==(lhs: ActiveApplicationInfo, rhs: ActiveApplicationInfo) -> Bool {
        return lhs.title == rhs.title
    }
}
