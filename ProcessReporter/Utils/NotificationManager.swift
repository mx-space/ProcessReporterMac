//
//  NotificationManager.swift
//  ProcessReporter
//
//  Created by Innei on 2023/8/12.
//

import UserNotifications

enum NotificationManager {
    
    // 请求通知权限
    static func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification authorization granted!")
            } else {
                print("Notification authorization denied!")
            }
        }
    }
    
    // 封装的发送通知的方法
    static func sendNotification(withMessage message: String) {
        let content = UNMutableNotificationContent()
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "ProcessReporter"
        content.title = appName // 你可以根据需要修改标题
        content.body = message
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }
}
