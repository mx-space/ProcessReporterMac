//
//  Reporter.swift
//  ProcessReporter
//
//  Created by Innei on 2023/6/24.
//

import AppKit
import SwiftJotai

class Reporter {
    public static var shared = Reporter()

    private var disposeReporingSub: Disposable?
    init() {
        disposeReporingSub = JotaiStore.shared.subscribe(atom: isReportingAtom) { [weak self] in
            let isReporting = JotaiStore.shared.get(isReportingAtom)
            debugPrint("isReporting: \(isReporting)")
            if isReporting {
                self?.startReporting()
            } else {
                self?.stopReporting()
            }
        }
    }

    deinit {
        disposeReporingSub?.dispose()
    }

    var timer: Timer?
    var subscribleDisposer: Disposable?

    private let lock = DispatchSemaphore(value: 1)

    func startReporting() {
        lock.wait() // 请求锁
        defer {
            lock.signal()
        }

        debugPrint("startReporting")
        if timer != nil {
            debugPrint("is already reporting")
            return
        }

        DispatchQueue.main.async {
            JotaiStore.shared.set(isReportingAtom, value: true)
        }

        subscribleDisposer = JotaiStore.shared.subscribe(atom: currentFrontAppAtom) {
            if Store.shared.reportType.contains(.process) {
                self.report()
            }
        }

        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in guard let self else { return }
            self.report()
        }

        report()
    }

    func stopReporting() {
        JotaiStore.shared.set(isReportingAtom, value: false)

        subscribleDisposer?.dispose()
        timer?.invalidate()

        timer = nil
    }

    func openSetting() {
        if #available(macOS 13, *) {
            NSApplication.shared.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApplication.shared.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }

    func isInited() -> Bool {
        return Store.shared.apiKey != "" && Store.shared.apiKey != ""
    }

    private func report() {
        let shouldReport = JotaiStore.shared.get(isReportingAtom)
        if !shouldReport {
            debugPrint("Report is disabled.")
            return
        }

        debugPrint("上报数据")

        let mediaInfo = getCurrnetPlaying()

        let endpoint = Store.shared.endpoint
        let apiKey = Store.shared.apiKey

        if endpoint == "" {
            debugPrint("endpoint not define")
            stopReporting()
            return
        }

        if apiKey == "" {
            debugPrint("apiKey not define")
            stopReporting()
            return
        }

        let url = URL(string: endpoint)

        guard let url else {
            debugPrint("endpoint parsing error")
            JotaiStore.shared.set(isReportingAtom, value: false)
            return
        }

        let workspace = NSWorkspace.shared
        let processName = workspace.frontmostApplication?.localizedName
        guard let processName else {
            debugPrint("app unkown")
            return
        }

        let now = Date()
        let timestamp: Int = Int(now.timeIntervalSince1970)

        var postData: PostData = PostData(timestamp: timestamp, key: apiKey)

        let processEnabled = Store.shared.reportType.contains(.process)
        let mediaEnabled = Store.shared.reportType.contains(.media)

        if !processEnabled && !mediaEnabled {
            debugPrint("There no info should update")
            return
        }

        if processEnabled {
            postData.process = processName
        }

        if mediaEnabled, let mediaInfo = mediaInfo {
            postData.media = mediaInfo
        }

        try? Request.shared.post(url: url, data: postData) { _ in
            DispatchQueue.main.async {
                JotaiStore.shared.set(lastReportAtAtom, value: now)
                JotaiStore.shared.set(lastReportDataAtom, value: postData)
            }
        }
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
}

struct MediaInfo: Codable, Equatable {
    var title: String
    var artist: String
}

struct PostData: Codable, Equatable {
    var timestamp: Int
    var key: String
    var process: String?
    var media: MediaInfo?
}
