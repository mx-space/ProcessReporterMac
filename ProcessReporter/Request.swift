//
//  Request.swift
//  ProcessReporter
//
//  Created by Innei on 2023/7/16.
//

import Foundation


class Request {
    static let shared = Request()

    func post(url: URL, data: [String: Any]) throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: data)

        let session = URLSession.shared

        let task = session.dataTask(with: request) { _, _, error in
            if let error = error {
                debugPrint("发生错误：\(error)")
            } else {
                debugPrint("请求成功")
                debugPrint("data: \(data)")
            }
        }

        task.resume()
    }
}
