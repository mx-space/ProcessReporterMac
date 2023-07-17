//
//  Store.swift
//  ProcessReporter
//
//  Created by Innei on 2023/6/24.
//

import Foundation

class Store: ObservableObject {
    @Persisted("reportType") var reportType: [ReportType] = [.media, .process]

    public static let shared = Store()
}
