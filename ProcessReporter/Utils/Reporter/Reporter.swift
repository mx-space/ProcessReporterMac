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

    private func sleepHandler() {
        let distributedNotificationCenter = DistributedNotificationCenter.default()

        distributedNotificationCenter.addObserver(
            self,
            selector: #selector(systemWillSleep),
            name: NSNotification.Name("com.apple.screenIsLocked"),
            object: nil
        )

        distributedNotificationCenter.addObserver(
            self,
            selector: #selector(systemDidWake),
            name: NSNotification.Name("com.apple.screenIsUnlocked"),
            object: nil
        )

        NotificationCenter.default.addObserver(self, selector: #selector(systemWillSleep), name: NSWorkspace.willSleepNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(systemDidWake), name: NSWorkspace.didWakeNotification, object: nil)
    }

    @objc func systemWillSleep(_ notification: Notification) {
        if let timer = timer {
            debugPrint("timer invalidate, sleeping")

            timer.invalidate()
        }
    }

    @objc func systemDidWake(_ notification: Notification) {
        let isReporting = JotaiStore.shared.get(Atoms.isReportingAtom)
        debugPrint("wake up, isReporting: \(isReporting)")
        if isReporting {
            startReporting()
        }
    }

    init() {
        sleepHandler()
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

//        debugPrint("上报数据")

        apiReport()
        slackStatusReport()
    }
}
