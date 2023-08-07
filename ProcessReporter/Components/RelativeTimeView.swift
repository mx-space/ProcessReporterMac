//
//  RelativeTime.swift
//  ProcessReporter
//
//  Created by Innei on 2023/8/8.
//

import SwiftUI

struct RelativeTimeView: View {
    @State private var now = Date()

    let startDate: Date
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(startDate: Date) {
        self.startDate = startDate
    }

    var body: some View {
        Text(relativeTime(from: startDate, to: now))
            .onReceive(timer) { _ in
                now = Date()
            }
    }

    func relativeTime(from startDate: Date, to endDate: Date) -> String {
        let componentsFormatter = DateComponentsFormatter()
        componentsFormatter.maximumUnitCount = 1
        componentsFormatter.unitsStyle = .full
        componentsFormatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
        componentsFormatter.zeroFormattingBehavior = .dropAll

        let timeInterval = endDate.timeIntervalSince(startDate)

        return (componentsFormatter.string(from: timeInterval) ?? "") + " ago"
    }
}

struct RelativeTime_Previews: PreviewProvider {
    static var previews: some View {
        RelativeTimeView(startDate: Date())
    }
}
