//
//  Reporter+API.swift
//  ProcessReporter
//
//  Created by Innei on 2023/8/12.
//

import AppKit
import SwiftJotai

struct PostData: Codable, Equatable {
    var timestamp: Int
    var key: String
    var process: String?
    var media: MediaInfo?
}

struct MediaInfo: Codable, Equatable {
    var title: String
    var artist: String
}

extension Reporter {
    private func getApiKey() -> String {
        JotaiStore.shared.get(Atoms.apiKeyAtom)
    }

    private func getEndpoint() -> String {
        JotaiStore.shared.get(Atoms.endpointAtom)
    }

    private func getApiReportEnabled() -> Bool {
        JotaiStore.shared.get(Atoms.apiReportEnabledAtom)
    }

    public func apiReport() {
        if getApiReportEnabled() == false {
            return
        }
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
            NotificationManager.sendNotification(withMessage: "[API]: endpoint url parsing error")
            JotaiStore.shared.set(Atoms.apiReportEnabledAtom, value: false)
            return
        }

        let now = Date()
        let timestamp: Int = Int(now.timeIntervalSince1970)

        var postData: PostData = PostData(timestamp: timestamp, key: apiKey)

        let processEnabled = Store.shared.reportType.contains(.process)
        let mediaEnabled = Store.shared.reportType.contains(.media)

        if processEnabled {
            let workspace = NSWorkspace.shared
            let processName = workspace.frontmostApplication?.localizedName
            guard let processName else {
                debugPrint("app unkown")
                return
            }

            postData.process = processName
        }

        if mediaEnabled {
            if let mediaInfo = getCurrnetPlaying() {
                postData.media = mediaInfo
            }
        }

        try? Request.shared.post(url: url, data: postData) { _ in
            DispatchQueue.main.async {
                JotaiStore.shared.set(Atoms.lastReportAtAtom, value: now)
                JotaiStore.shared.set(Atoms.lastReportDataAtom, value: postData)
            }
        }
    }
}
