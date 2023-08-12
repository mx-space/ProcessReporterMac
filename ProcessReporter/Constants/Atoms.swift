//
//  Atoms.swift
//  ProcessReporter
//
//  Created by Innei on 2023/7/16.
//

import SwiftJotai

@MainActor
enum Atoms {
    static let isReportingAtom = Atom(userDefaultsKey: "enableAppReport", defaultValue: false)

    static let currentFrontAppAtom = Atom<String?>(nil)

    static let updateIntervalAtom = Atom(userDefaultsKey: "update-interval", defaultValue: 60)

    // API Report
    static let apiReportEnabledAtom = Atom(userDefaultsKey: "apiReportEnabled", defaultValue: true)
    static let apiKeyAtom = Atom(userDefaultsKey: "apiKey", defaultValue: "")
    static let endpointAtom = Atom(userDefaultsKey: "endpoint", defaultValue: "")
    static let lastReportAtAtom = Atom<Date?>(nil)
    static let lastReportDataAtom = Atom<PostData?>(nil)

    // Slack report
    static let slackReportEnabledAtom = Atom(userDefaultsKey: "slackReportEnabled", defaultValue: true)
    static let slackApiTokenAtom = Atom(userDefaultsKey: "slack_token", defaultValue: "")
    static let slackStatusEmojiAtom = Atom(userDefaultsKey: "slack_status_emoji", defaultValue: Defaults.SlackStatus.emoji)
    static let slackStatusTextFormatterAtom = Atom(userDefaultsKey: "slack_status_formatter", defaultValue:
        Defaults.SlackStatus.formatter)
    static let lastSlackStatusAtom = Atom<String?>(nil)

    static let networkOnlineAtom = Atom(true)
}

let JotaiStore = SwiftJotai.Store.self
