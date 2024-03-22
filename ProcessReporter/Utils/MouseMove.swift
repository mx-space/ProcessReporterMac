//
//  MouseMove.swift
//  ProcessReporter
//
//  Created by Innei on 2024/3/22.
//

import Cocoa
import AppKit
import Accessibility

func monitorMouseMove() {
    
 
    var lastSelectedText = ""
    var info : ActiveApplicationInfo = ActiveApplicationObserver.shared.getActiveApplicationInfo()
    NSEvent.addGlobalMonitorForEvents(matching:
                                        [.leftMouseUp, .keyDown]
    ) { (event) in
        
        switch event.type {
        case .leftMouseUp, .keyDown:
        
            var currentInfo = ActiveApplicationObserver.shared.getActiveApplicationInfo()
          
            if currentInfo != info {
                
                DispatchQueue.main.async {
                    Reporter.shared.report()
                }
            }
            info = currentInfo
            break
            
        default:
            break
        }
     
    }
    
}
