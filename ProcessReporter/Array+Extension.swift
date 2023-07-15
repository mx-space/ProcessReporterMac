//
//  Array+Extension.swift
//  ProcessReporter
//
//  Created by Innei on 2023/7/16.
//

import Foundation

extension Array where Element: Equatable {
    mutating func addOrRemove(_ element: Element) {
        if let index = firstIndex(of: element) {
            
            debugPrint("remove at \( index)" )
            remove(at: index)
        } else {
            append(element)
        }
    }
}
