//
//  Store.swift
//  ProcessReporter
//
//  Created by Innei on 2023/6/24.
//

import Foundation

class Store: ObservableObject {
    init() {
        let apiKey = (UserDefaults.standard.string(forKey: "apiKey")) ?? ""
        let endpoint = UserDefaults.standard.string(forKey: "endpoint") ?? ""

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
