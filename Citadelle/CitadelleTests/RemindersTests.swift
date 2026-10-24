//
//  RemindersTests.swift
//  CitadelleTests
//

import Foundation
import Testing
@testable import Citadelle

struct ReminderPlannerTests {

    private let library = Fixtures.library()

    private func settings(_ kind: ReminderKind, hour: Int, minute: Int) -> [ReminderKind: ReminderSetting] {
        [kind: ReminderSetting(isEnabled: true, hour: hour, minute: minute)]
    }

    @Test func disabledRemindersScheduleNothing() {
        let plan = ReminderPlanner.plan(settings: [.wakeUp: ReminderSetting(isEnabled: false, hour: 7, minute: 0)],
                                        library: library)
        #expect(plan.isEmpty)
    }

    @Test func anEnabledReminderFiresDailyAtItsTimeForItsSituation() throws {
        let plan = ReminderPlanner.plan(settings: settings(.wakeUp, hour: 6, minute: 45), library: library)
        let reminder = try #require(plan.first)

        #expect(plan.count == 1)
        #expect(reminder.identifier == "reminder.wakeUp")
        #expect(reminder.hour == 6 && reminder.minute == 45)
        #expect(reminder.chapterID == ReminderKind.wakeUp.chapterID)
        #expect(reminder.title == "Au réveil")
    }

    @Test func theNotificationShowsTheFirstDuaToRecite() throws {
        let plan = ReminderPlanner.plan(settings: settings(.wakeUp, hour: 6, minute: 0), library: library)
        let body = try #require(plan.first?.body)

        // Chapter 1's first dua in book order is 11.
        #expect(body.contains("Louange à Allah"))
    }

    @Test func longTextsAreShortenedForTheLockScreen() {
        let long = String(repeating: "Louange à Allah. ", count: 40)
        let shortened = ReminderPlanner.preview(of: long)

        #expect(shortened.count <= ReminderPlanner.maxBodyLength + 1)
        #expect(shortened.hasSuffix("…"))
        #expect(ReminderPlanner.preview(of: "Court.") == "Court.")
    }

    @Test func remindersForMissingSituationsAreSkipped() {
        let plan = ReminderPlanner.plan(settings: settings(.evening, hour: 18, minute: 0), library: library)
        #expect(plan.isEmpty)
    }
}

@MainActor
struct ReminderSettingsStoreTests {

    private func makeDefaults() -> UserDefaults {
        UserDefaults(suiteName: "ReminderSettingsStoreTests-\(UUID().uuidString)")!
    }

    @Test func everyReminderStartsOffWithASensibleTime() {
        let store = ReminderSettingsStore(defaults: makeDefaults())

        for kind in ReminderKind.allCases {
            #expect(!store.setting(for: kind).isEnabled)
            #expect((0...23).contains(store.setting(for: kind).hour))
        }
    }

    @Test func changesSurviveRelaunch() {
        let defaults = makeDefaults()
        ReminderSettingsStore(defaults: defaults)
            .update(.morning, to: ReminderSetting(isEnabled: true, hour: 7, minute: 30))

        let reloaded = ReminderSettingsStore(defaults: defaults).setting(for: .morning)
        #expect(reloaded == ReminderSetting(isEnabled: true, hour: 7, minute: 30))
    }
}
