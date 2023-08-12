//
//  Atoms.swift
//  ProcessReporter
//
//  Created by Innei on 2023/7/16.
//

import SwiftJotai

@MainActor
enum Atoms {
    static let isReportingAtom = Atom(false)

    static let lastReportAtAtom = Atom<Date?>(nil)
    static let lastReportDataAtom = Atom<PostData?>(nil)

    static let currentFrontAppAtom = Atom<String?>(nil)

    static let updateIntervalAtom = Atom(userDefaultsKey: "update-interval", defaultValue: 60)

    // API Report
    static let apiReportEnabledAtom = Atom(userDefaultsKey: "apiReportEnabled", defaultValue: true)
    static let apiKeyAtom = Atom(userDefaultsKey: "apiKey", defaultValue: "")
    static let endpointAtom = Atom(userDefaultsKey: "endpoint", defaultValue: "")
    
    // Slack report
    static let slackReportEnabledAtom = Atom(userDefaultsKey: "slackReportEnabled", defaultValue: true)
    static let slackApiTokenAtom = Atom(userDefaultsKey: "slack_token", defaultValue: "")
    static let slackStatusEmojiAtom = Atom(userDefaultsKey: "slack_status_emoji", defaultValue: Constants.SlackStatusDefault.emoji)
    static let slackStatusTextFormatterAtom = Atom(userDefaultsKey: "slack_status_formatter", defaultValue:
                                                    Constants.SlackStatusDefault.formatter)
    
    static let networkOnlineAtom = Atom(true)
}

let JotaiStore = SwiftJotai.Store.self
