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
}

let JotaiStore = SwiftJotai.Store.self
