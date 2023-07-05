//
//  Store.swift
//  ProcessReporter
//
//  Created by Innei on 2023/6/24.
//

import Foundation

class Store: ObservableObject {
    init() {
//        #if DEBUG
        let apiKey = (UserDefaults.standard.string(forKey: "apiKey")) ?? ""
        let endpoint = UserDefaults.standard.string(forKey: "endpoint") ?? ""
//        #else
//        let apiKey = "testing"
//        let endpoint = "http://127.0.0.1:2333/fn/ps/update"
//        #endif
        self.apiKey = apiKey
        self.endpoint = endpoint
    }

    @Published var apiKey = "" {
        didSet {
            UserDefaults.standard.setValue(apiKey, forKey: "apiKey")
        }
    }

    @Published var endpoint = "" {
        didSet {
            UserDefaults.standard.setValue(endpoint, forKey: "endpoint")
        }
    }

    @Published var isReporting = false

    public static let shared = Store()
}
