//
//  Atoms.swift
//  ProcessReporter
//
//  Created by Innei on 2023/7/16.
//

import SwiftJotai

let isReportingAtom = Atom(false)

let lastReportAtAtom = Atom<Date?>(nil)
let lastReportDataAtom = Atom<PostData?>(nil)

let currentFrontAppAtom = Atom<String?>(nil)

let JotaiStore = SwiftJotai.Store.self
