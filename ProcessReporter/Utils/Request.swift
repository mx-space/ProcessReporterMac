//
//  Request.swift
//  ProcessReporter
//
//  Created by Innei on 2023/7/16.
//

import Foundation

class Request {
    static let shared = Request()

    func post<T: Encodable>(url: URL,
                            data: T,
                            timeout: TimeInterval = 3.0,
                            headers: [String: String]? = nil,
                            callback: ((Any?) -> Void)? = nil,
                            errorCallback: ((Any?) -> Void)? = nil

    ) throws {
        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = "POST"

        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }

        request.httpBody = try? JSONEncoder().encode(data)

        let session = URLSession.shared

        let task = session.dataTask(with: request) { response, _, error in
            if let error = error {
                debugPrint("发生错误：\(error)")
                errorCallback?(error)
            } else {
                debugPrint("请求成功 \(data)")
                callback?(response)
            }
        }

        task.resume()
    }
}
