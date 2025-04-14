import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleExpiringSoonNotification(for items: [InventoryItem]) {
        guard !items.isEmpty else { return }
        
        let content = UNMutableNotificationContent()
        
        if items.count == 1 {
            content.title = "Item Expiring Soon"
            content.body = "\(items[0].name) is expiring \(formatExpirationDate(items[0].expirationDate))"
        } else {
            content.title = "Items Expiring Soon"
            content.body = "\(items.count) items are expiring soon"
        }
        
        content.sound = .default
        
        // Schedule for the next day at 9 AM
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        components.hour = 16
        components.minute = 32
        
        // If it's past 9 AM, schedule for tomorrow
        if let today = calendar.date(from: components), today < Date() {
            components.day = (components.day ?? 0) + 1
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "expiring_soon_group", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling expiring soon notification: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleExpiredNotification(for items: [InventoryItem]) {
        guard !items.isEmpty else { return }
        
        let content = UNMutableNotificationContent()
        
        if items.count == 1 {
            content.title = "Item Expired"
            content.body = "\(items[0].name) has expired today"
        } else {
            content.title = "Items Expired"
            content.body = "\(items.count) items have expired today"
        }
        
        content.sound = .default
        
        // Schedule for today at 9 AM
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        components.hour = 9
        components.minute = 0
        
        // If it's past 9 AM, schedule for tomorrow
        if let today = calendar.date(from: components), today < Date() {
            components.day = (components.day ?? 0) + 1
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "expired_group", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling expired notification: \(error.localizedDescription)")
            }
        }
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func formatExpirationDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
} 
