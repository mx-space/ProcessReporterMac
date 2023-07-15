//
//  Persist+Modifier.swift
//  ProcessReporter
//
//  Created by Innei on 2023/7/16.
//
import SwiftUI

@propertyWrapper
struct Persisted<Value: Codable> {
     
    
    
    let key: String
    var value: Value?

    init(wrappedValue: Value, _ key: String = #function) {
        self.key = key
        value = wrappedValue
    }

    var wrappedValue: Value {
        get {
            // Get the value from UserDefaults
            guard let data = UserDefaults.standard.data(forKey: key),
                  let decodedValue = try? JSONDecoder().decode(Value.self, from: data) else {
                // If no value is found or decoding fails, return the initial value
                return value!
            }

            // Return the decoded value
            return decodedValue
        }
        set {
            // Try to encode the new value and save it to UserDefaults
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: key)
            }
            
            Store.shared.objectWillChange.send()
        }
    }
}
