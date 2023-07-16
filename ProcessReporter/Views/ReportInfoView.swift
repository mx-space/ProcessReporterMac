//
//  ReportInfoView.swift
//  ProcessReporter
//
//  Created by Innei on 2023/7/16.
//

import SwiftJotai
import SwiftUI

struct ReportInfoView: View {
    @StateObject var lastReportAt = AtomValue(lastReportAtAtom)
    @StateObject var lastReportData = AtomValue(lastReportDataAtom)
    @StateObject var currentProcess = AtomValue(currentFrontAppAtom)

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
                        Button("Last Report At: \(lastReportTime.formatted(.dateTime.hour().minute().second()))") {}
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
