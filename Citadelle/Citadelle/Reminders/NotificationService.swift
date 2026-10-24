//
//  NotificationService.swift
//  Citadelle
//

import Foundation
import UserNotifications

/// Applies a reminder plan to the system's notification schedule.
enum NotificationService {
    static let chapterKey = "chapterID"

    /// Asks once; returns whether notifications are allowed.
    static func requestPermission() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])) ?? false
    }

    static func apply(_ plan: [PlannedReminder]) async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        center.removePendingNotificationRequests(withIdentifiers: pending.map(\.identifier)
            .filter { $0.hasPrefix(ReminderPlanner.identifierPrefix) })

        for reminder in plan {
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default
            content.userInfo = [chapterKey: reminder.chapterID]
            var time = DateComponents()
            time.hour = reminder.hour
            time.minute = reminder.minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
            try? await center.add(UNNotificationRequest(identifier: reminder.identifier, content: content, trigger: trigger))
        }
    }

    /// Shows a reminder right away (used by the Shortcuts action).
    static func showNow(title: String, body: String, chapterID: Int) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = [chapterKey: chapterID]
        try? await UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: "now.\(chapterID).\(UUID().uuidString)", content: content, trigger: nil)
        )
    }
}
