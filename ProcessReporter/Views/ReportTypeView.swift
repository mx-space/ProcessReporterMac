//
//  ReportTypeView.swift
//  ProcessReporter
//
//  Created by Innei on 2023/7/16.
//

import SwiftUI

struct ReportTypeView: View {
    @EnvironmentObject var store: Store

    func bindingForReportType(_ reportType: ReportType) -> Binding<Bool> {
        Binding<Bool>(
            get: { store.reportType.contains(reportType) },
            set: { _ in store.reportType.addOrRemove(reportType) }
        )
    }

    var isMediaReport: Binding<Bool> { bindingForReportType(ReportType.media) }
    var isProcessReport: Binding<Bool> { bindingForReportType(ReportType.process) }

    var isAllReport: Binding<Bool> {
        Binding<Bool>(
            get: { store.reportType.contains(.media) && store.reportType.contains(.process) },
            set: {
                if $0 {
                    store.reportType = [.media, .process]
                } else {
                    store.reportType = []
                }
            }
        )
    }

    var body: some View {
        Group {
            Toggle("Report Media", isOn: isMediaReport)
            Toggle("Report Process", isOn: isProcessReport)
            Toggle("Report All", isOn: isAllReport)
        }
    }
}

struct ReportTypeView_Previews: PreviewProvider {
    static var previews: some View {
        ReportTypeView()
    }
}
