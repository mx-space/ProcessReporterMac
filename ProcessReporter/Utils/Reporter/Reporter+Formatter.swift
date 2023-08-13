//
//  Reporter+Formatter.swift
//  ProcessReporter
//
//  Created by Innei on 2023/8/12.
//

import AppKit

extension Reporter {
    public func stringFormatter(text: String) -> String? {
        let processEnabled = Store.shared.reportType.contains(.process)
        let mediaEnabled = Store.shared.reportType.contains(.media)

        var mediaInfo: MediaInfo?

        if mediaEnabled {
            if let _mediaInfo = getCurrnetPlaying() {
                mediaInfo = _mediaInfo
            }
        }

        var processName: String?
        if processEnabled {
            let workspace = NSWorkspace.shared
            processName = workspace.frontmostApplication?.localizedName
        }

        var finalText = text

        if let processName = processName {
            finalText = finalText.replacingOccurrences(of: "{process_name}", with: processName)
        } else {
            if finalText.contains("{process_name}") {
                debugPrint("process name missing")
                return nil
            }
        }

        if let mediaInfo = mediaInfo {
            finalText = finalText.replacingOccurrences(of: "{media_name}", with: mediaInfo.title)
            finalText = finalText.replacingOccurrences(of: "{media_artist}", with: mediaInfo.artist)
        } else {
           
            if finalText.contains("{media_name}") || finalText.contains("{media_artist}") {
                debugPrint("media info missing")
                return nil
            }
        
        }

        return finalText
    }
}
