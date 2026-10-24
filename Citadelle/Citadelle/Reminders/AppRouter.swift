//
//  AppRouter.swift
//  Citadelle
//

import Foundation
import Observation
import UIKit
import UserNotifications

/// Opens a situation requested from outside the app's own navigation:
/// a tapped notification or a Shortcuts action.
@Observable
final class AppRouter {
    static let shared = AppRouter()

    var pendingChapterID: Int?

    func open(chapterID: Int) {
        pendingChapterID = chapterID
    }
}

/// Receives taps on reminders and lets them show while the app is open.
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            didReceive response: UNNotificationResponse) async {
        guard let chapterID = response.notification.request.content.userInfo[NotificationService.chapterKey] as? Int
        else { return }
        await MainActor.run { AppRouter.shared.open(chapterID: chapterID) }
    }
}
