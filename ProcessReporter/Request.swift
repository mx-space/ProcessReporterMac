//
//  Request.swift
//  ProcessReporter
//
//  Created by Innei on 2023/7/16.
//

import Foundation

class Request {
    static let shared = Request()

    func post<T: Encodable>(url: URL, data: T, callback: ((Any?) -> Void)? = nil) throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(data)

        let session = URLSession.shared

        let task = session.dataTask(with: request) { response, _, error in
            if let error = error {
                debugPrint("发生错误：\(error)")
            } else {
                debugPrint("请求成功 \(data)")
                callback?(response)
            }
        }

        task.resume()
    }
}
