//
//  Agent.swift
//  ProcessReporter
//
//  Created by Innei on 2023/7/15.
//

import LaunchAtLogin

enum BundleError: Error {
    case NotFound
}

class Agent {
    func enableLaunchAtLogin(_ enabled: Bool) {
        LaunchAtLogin.isEnabled = enabled
    }

    public static let shared = Agent()
}
