//
//  Reporter+API.swift
//  ProcessReporter
//
//  Created by Innei on 2023/8/12.
//

import AppKit
import SwiftJotai

let stackEndpoint = "https://slack.com/api/users.profile.set"

fileprivate struct ProfileData: Codable {
    var status_text: String
    var status_emoji: String
    var status_expiration: Int
}

extension Reporter {
    public func slackStatusReport() {
        if !JotaiStore.shared.get(Atoms.slackReportEnabledAtom) {
            return
        }

        let emoji = JotaiStore.shared.get(Atoms.slackStatusEmojiAtom)
        var formatter = JotaiStore.shared.get(Atoms.slackStatusTextFormatterAtom)

        if formatter.count == 0 {
            formatter = Defaults.SlackStatus.formatter
        }

        let url = URL(string: stackEndpoint)!

        let statusText = stringFormatter(text: formatter)

        guard let statusText = statusText else {
            return
        }

        let statusEmoji = emoji.count > 0 ? String(emoji.first!) : ""

        let statusExpiration = {
            let currentDate = Date()
            return Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!.timeIntervalSince1970
        }()

        let postData = [
            "profile": ProfileData(status_text: statusText, status_emoji: statusEmoji, status_expiration: Int(statusExpiration)),
        ]

        let token = JotaiStore.shared.get(Atoms.slackApiTokenAtom)

        if token.count == 0 {
            JotaiStore.shared.set(Atoms.slackReportEnabledAtom, value: false)
            NotificationManager.sendNotification(withMessage: "Missing Slack Token")
            return
        }

        try? Request.shared.post(url: url, data: postData, headers: [
            "Authorization": "Bearer " + token,
        ], callback: { _ in
            DispatchQueue.main.async {
                JotaiStore.shared.set(Atoms.lastSlackStatusAtom, value: statusEmoji + statusText)
            }
        },
        errorCallback: { error in

            debugPrint(error, "error")
//            NotificationManager.sendNotification(withMessage: error)
        })
    }
}
