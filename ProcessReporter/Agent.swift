//
//  Agent.swift
//  ProcessReporter
//
//  Created by Innei on 2023/7/15.
//

import Foundation
import LaunchAtLogin

enum BundleError: Error {
    case NotFound
}

class Agent {
    func enableLaunchAtLogin(_ enabled: Bool) {
        LaunchAtLogin.isEnabled = enabled
    }

    public static let shared = Agent()

    func getApplist() {
        let fileManager = FileManager.default
        let applicationsURL = URL(fileURLWithPath: "/Applications", isDirectory: true)

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: applicationsURL,
                                                               includingPropertiesForKeys: nil,
                                                               options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            for fileURL in fileURLs {
                if fileURL.pathExtension == "app" {
                    print(fileURL.deletingPathExtension().lastPathComponent)
                }
            }
        } catch {
            print("Error while enumerating files \(applicationsURL.path): \(error.localizedDescription)")
        }
    }
}
