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

    static let apiKeyAtom = Atom(userDefaultsKey: "apiKey", defaultValue: "")
    static let endpointAtom = Atom(userDefaultsKey: "endpoint", defaultValue: "")
}

let JotaiStore = SwiftJotai.Store.self