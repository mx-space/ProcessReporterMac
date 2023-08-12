//
//  Reporter+Media.swift
//  ProcessReporter
//
//  Created by Innei on 2023/8/12.
//


extension Reporter {
    func getCurrnetPlaying() -> MediaInfo? {
        let args: [String] = ["", "get", "title", "artist"]

        var cArgs = args.map { $0.withCString(strdup) }
        var infoFromOC: String?

        cArgs.withUnsafeMutableBufferPointer { buffer in
            let argc = Int32(buffer.count)
            let argv = buffer.baseAddress

            let result = NowPlaying.processCommand(withArgc: argc, argv: argv)

            infoFromOC = result
        }

        for ptr in cArgs { free(ptr) }

        if let info = infoFromOC {
            let arr = info.split(separator: "\n")
            let filterArr = arr.filter { sub in
                sub != "null"
            }

            if filterArr.count < 2 {
                return nil
            }
            let mediaInfo = MediaInfo(title: String(filterArr[0]), artist: String(filterArr[1]))

            return mediaInfo
        }
        return nil
    }
}
