//
//  Reporter.swift
//  ProcessReporter
//
//  Created by Innei on 2023/6/24.
//

import AppKit
import Network
import SwiftJotai

fileprivate enum NetworkObserver {
    static let monitor = NWPathMonitor()
    static let queue = DispatchQueue(label: "NetworkMonitor")

    static func observe(
        onConnect: (() -> Void)? = nil,
        onDisconnect: (() -> Void)? = nil
    ) {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                debugPrint("We're connected!")
                onConnect?()
            } else {
                debugPrint("No connection.")
                onDisconnect?()
            }
        }

        monitor.start(queue: queue)
    }

    static func getCurrentNetworkStatus() -> NWPath.Status {
        return monitor.currentPath.status
    }
}

@MainActor
class Reporter {
    public static var shared = Reporter()

    private var disposerList = [Disposable]()

    init() {
        let d1 = JotaiStore.shared.subscribe(atom: Atoms.isReportingAtom) { [weak self] in
            let isReporting = JotaiStore.shared.get(Atoms.isReportingAtom)
            debugPrint("isReporting: \(isReporting)")
            if isReporting {
                self?.startReporting()
            } else {
                self?.stopReporting()
            }
        }

        let d2 = JotaiStore.shared.subscribe(atom: Atoms.updateIntervalAtom) { [weak self] in
            guard let self = self else { return }
            guard self.timer != nil else { return }
            let isReporting = JotaiStore.shared.get(Atoms.isReportingAtom)
            if !isReporting {
                return
            }
            self.stopReporting()

            self.startReporting()
        }

        disposerList.append(contentsOf: [d1, d2])

        // detect network
        let networkStatus = NetworkObserver.getCurrentNetworkStatus()
        switch networkStatus {
        case .satisfied:
            JotaiStore.shared.set(Atoms.networkOnlineAtom, value: true)
        case .requiresConnection, .unsatisfied:
            JotaiStore.shared.set(Atoms.networkOnlineAtom, value: false)
        @unknown default: JotaiStore.shared.set(Atoms.networkOnlineAtom, value: false)
        }

        NetworkObserver.observe {
            JotaiStore.shared.set(Atoms.networkOnlineAtom, value: true)
        } onDisconnect: {
            JotaiStore.shared.set(Atoms.networkOnlineAtom, value: false)
        }
    }

    deinit {
        disposerList.forEach { $0.dispose() }
    }

    var timer: Timer?
    var subscribleDisposer: Disposable?

    private let lock = DispatchSemaphore(value: 1)

    func startReporting() {
        lock.wait()
        defer {
            lock.signal()
        }

        debugPrint("startReporting")
        if timer != nil {
            debugPrint("is already reporting")
            return
        }

        DispatchQueue.main.async {
            JotaiStore.shared.set(Atoms.isReportingAtom, value: true)
        }

        subscribleDisposer = JotaiStore.shared.subscribe(atom: Atoms.currentFrontAppAtom) {
            if Store.shared.reportType.contains(.process) {
                self.report()
            }
        }

        let interval = TimeInterval(JotaiStore.shared.get(Atoms.updateIntervalAtom))

        timer = Timer.scheduledTimer(withTimeInterval: max(interval, 1.0), repeats: true) { _ in
            Task {
                await MainActor.run {
                    self.report()
                }
            }
        }

        report()
    }

    func stopReporting() {
        JotaiStore.shared.set(Atoms.isReportingAtom, value: false)

        subscribleDisposer?.dispose()
        timer?.invalidate()

        timer = nil
    }

    func isInited() -> Bool {
        let apiKey = getApiKey()
        let endpoint = getEndpoint()
        return apiKey != "" && endpoint != ""
    }

    private func report() {
        let shouldReport = JotaiStore.shared.get(Atoms.isReportingAtom)
        if !shouldReport {
            debugPrint("Report is disabled.")
            return
        }

        let isOnline = JotaiStore.shared.get(Atoms.networkOnlineAtom)

        if !isOnline {
            debugPrint("Network offline")
            return
        }

        let processEnabled = Store.shared.reportType.contains(.process)
        let mediaEnabled = Store.shared.reportType.contains(.media)

        if !processEnabled && !mediaEnabled {
            debugPrint("There no info should update")
            return
        }

        debugPrint("上报数据")

        apiReport()
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

extension Reporter {
    private func getApiKey() -> String {
        JotaiStore.shared.get(Atoms.apiKeyAtom)
    }

    private func getEndpoint() -> String {
        JotaiStore.shared.get(Atoms.endpointAtom)
    }

    public func apiReport() {
        let endpoint = getEndpoint()
        let apiKey = getApiKey()

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
            JotaiStore.shared.set(Atoms.isReportingAtom, value: false)
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

        if processEnabled {
            postData.process = processName
        }

        let mediaInfo = getCurrnetPlaying()
        if mediaEnabled, let mediaInfo = mediaInfo {
            postData.media = mediaInfo
        }

        try? Request.shared.post(url: url, data: postData) { _ in
            DispatchQueue.main.async {
                JotaiStore.shared.set(Atoms.lastReportAtAtom, value: now)
                JotaiStore.shared.set(Atoms.lastReportDataAtom, value: postData)
            }
        }
    }
}

extension Reporter {
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
