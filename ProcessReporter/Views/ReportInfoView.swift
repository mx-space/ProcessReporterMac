//
//  ReportInfoView.swift
//  ProcessReporter
//
//  Created by Innei on 2023/7/16.
//

import SwiftJotai
import SwiftUI

struct ReportInfoView: View {
    @StateObject var lastReportAt = AtomValue(Atoms.lastReportAtAtom)
    @StateObject var lastReportData = AtomValue(Atoms.lastReportDataAtom)
    @StateObject var currentProcess = AtomValue(Atoms.currentFrontAppAtom)

    let formatter = RelativeDateTimeFormatter()

    var body: some View {
        Group {
            Section("Current Process") {
                Button(currentProcess.value ?? "N/A") {}
            }

            if let lastReportData = lastReportData.value {
                Divider()
                Section("Last report") {
                    Button("Last Report Process: \(lastReportData.process ?? "")") {}

                    if let media = lastReportData.media {
                        Button("Last Report Media: \(media.artist) - \(media.title)") {}
                    }

                    if let lastReportTime = lastReportAt.value {
                        Button(action: {}) {
//                            Text("Last Report At: \(formatter.localizedString(for: lastReportTime, relativeTo: Date.now))")

                            Text(lastReportTime, style: .relative)
                        }
                    }
                }
            }
        }
    }
}

struct ReportInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ReportInfoView()
    }
}
