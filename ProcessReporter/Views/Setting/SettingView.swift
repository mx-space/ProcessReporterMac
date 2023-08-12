//
//  SettingView.swift
//  ProcessReporter
//
//  Created by Innei on 2023/6/24.
//

import Combine
import LaunchAtLogin
import SwiftJotai
import SwiftUI

struct SettingView: View {
    @State private var launchAtLogin = false
    @StateObject var updateInterval = AtomValue(Atoms.updateIntervalAtom)

    private enum Tabs: Hashable {
        case general
        case integration
    }

    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimum = .init(integerLiteral: 1)
        formatter.maximum = .init(integerLiteral: Int.max)
        formatter.generatesDecimalNumbers = false
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    var body: some View {
        TabView {
            Form {
                LaunchAtLogin.Toggle {
                    Text("Launch at login")
                }

                TextField("Report interval", value: updateInterval.binding, formatter: numberFormatter)
            }
            .padding(20)

            .tabItem {
                Label("General", systemImage: "gear")
            }
            .tag(Tabs.general)

            IntergrationView()
                .tabItem {
                    Label("Integration", systemImage: "puzzlepiece.extension")
                }
                .tag(Tabs.integration)
        }.frame(width: 500)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}

struct RangeIntegerStyle: ParseableFormatStyle {
    var parseStrategy: RangeIntegerStrategy = .init()
    let range: ClosedRange<Int>

    func format(_ value: Int) -> String {
        let constrainedValue = min(max(value, range.lowerBound), range.upperBound)
        return "\(constrainedValue)"
    }
}

struct RangeIntegerStrategy: ParseStrategy {
    func parse(_ value: String) throws -> Int {
        return Int(value) ?? 1
    }
}

extension FormatStyle where Self == RangeIntegerStyle {
    static func ranged(_ range: ClosedRange<Int>) -> RangeIntegerStyle {
        return RangeIntegerStyle(range: range)
    }
}
