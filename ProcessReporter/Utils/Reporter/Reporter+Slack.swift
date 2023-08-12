//
//  Reporter+API.swift
//  ProcessReporter
//
//  Created by Innei on 2023/8/12.
//

import AppKit
import SwiftJotai

let stackEndpoint = "https://slack.com/api/users.profile.set"

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
        let statusEmoji = emoji.count > 0 ? String(emoji.first!) : ""

        let postData = [
            "profile": ["status_text": statusText,
                        "status_emoji": statusEmoji,
            ],
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
