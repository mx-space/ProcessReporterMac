//
//  Reporter.swift
//  ProcessReporter
//
//  Created by Innei on 2023/6/24.
//

import AppKit

class Reporter {
    public static var shared = Reporter()

    var timer: Timer?

    func startReporting() {
        Store.shared.isReporting = true

        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in

            debugPrint("上报数据")

            var endpoint = Store.shared.endpoint
            var apiKey = Store.shared.apiKey

            if endpoint == nil {
                debugPrint("endpoint not define")
                Store.shared.isReporting = false
                return
            }

            if apiKey == nil {
                debugPrint("apiKey not define")
                Store.shared.isReporting = false
                return
            }

            let url = URL(string: endpoint)

            guard (url != nil) else {
                debugPrint("endpoint parsing error")
                Store.shared.isReporting = false
                return
            }

            let workspace = NSWorkspace.shared
            let frontmostApp = workspace.frontmostApplication
            guard (frontmostApp?.localizedName) != nil else {
                debugPrint("app unkown")
                return
            }
            let processName = frontmostApp?.localizedName

            let timestamp = Date().timeIntervalSince1970

            let postData: [String: Any] = [
                "process": processName,
                "timestamp": timestamp,
                "key": apiKey,
            ]

            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: postData)

            let session = URLSession.shared

            let task = session.dataTask(with: request) { _, _, error in

                debugPrint(postData)
                if let error = error {
                    debugPrint("发生错误：\(error)")
                } else {
                    debugPrint("请求成功")
                }
            }

            task.resume()
        }
    }

    func stopReporting() {
        Store.shared.isReporting = false
        timer?.invalidate()
        timer = nil
    }
    
    func setting() {
        if #available(macOS 13, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }
    
    func isInited() -> Bool {
        return Store.shared.apiKey != nil && Store.shared.apiKey != nil
    }
}
