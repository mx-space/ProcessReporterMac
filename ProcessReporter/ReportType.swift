//
//  ReportType.swift
//  ProcessReporter
//
//  Created by Innei on 2023/7/16.
//

import Foundation

enum ReportType: String, Codable, CaseIterable {
    case media
    case process
    case all

    static var allCasesExceptAll: [ReportType] {
        return allCases.filter { $0 != .all }
    }
}
