//
//  Reporter.swift
//  ProcessReporter
//
//  Created by Innei on 2023/6/24.
//

import AppKit
import ScriptingBridge
import MediaPlayer

class Reporter {
    public static var shared = Reporter()

    var timer: Timer?

    func startReporting() {
        Store.shared.isReporting = true

        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in

            debugPrint("上报数据")
            
            let mediaInfo = self.getCurrnetPlaying()

            let endpoint = Store.shared.endpoint
            let apiKey = Store.shared.apiKey

            if endpoint == "" {
                debugPrint("endpoint not define")
                Store.shared.isReporting = false
                return
            }

            if apiKey == "" {
                debugPrint("apiKey not define")
                Store.shared.isReporting = false
                return
            }

            let url = URL(string: endpoint)

            guard url != nil else {
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

            var postData: [String: Any] = [
                "process": processName ?? "",
                "timestamp": timestamp,
                "key": apiKey,
            ]

            if let mediaInfo = mediaInfo {
                postData["media"] = [
                    "title": mediaInfo.title,
                    "artist": mediaInfo.artist,
                ]
            }

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
        return Store.shared.apiKey != "" && Store.shared.apiKey != ""
    }

    func getCurrnetPlaying() -> MediaInfo? {
        let args: [String] = ["", "get", "title", "artist"]

        var cArgs = args.map { $0.withCString(strdup) }
        var infoFromOC: String?

        cArgs.withUnsafeMutableBufferPointer { buffer in
            let argc = Int32(buffer.count)
            let argv = buffer.baseAddress

            let result = NowPlaying.processCommand(withArgc: argc, argv: argv)

            infoFromOC = result
        }

        for ptr in cArgs { free(ptr) }

        if let info = infoFromOC {
            let arr = info.split(separator: "\n")
            let filterArr = arr.filter { sub in
                sub != "null"
            }
            
            if filterArr.count < 2 {
                return nil
            }
            let mediaInfo = MediaInfo(title: String(filterArr[0]), artist: String(filterArr[1]))

            return mediaInfo
        }
        return nil
    }
    
    
    func getMusicApp() {
        
    }
}

struct MediaInfo {
    var title: String
    var artist: String
}
