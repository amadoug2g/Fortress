//
//  Reminders.swift
//  Citadelle
//
//  Daily reminders: what to schedule (pure, tested) and where the user's
//  choices are kept.
//

import Foundation
import Observation

nonisolated enum ReminderKind: String, CaseIterable, Codable, Sendable, Identifiable {
    case wakeUp, morning, evening, bedtime

    var id: String { rawValue }

    /// The situation the reminder opens.
    var chapterID: Int {
        switch self {
        case .wakeUp: 1
        case .morning: 27
        case .evening: 1027
        case .bedtime: 28
        }
    }

    var defaultTime: (hour: Int, minute: Int) {
        switch self {
        case .wakeUp: (6, 30)
        case .morning: (7, 0)
        case .evening: (17, 30)
        case .bedtime: (22, 30)
        }
    }
}

nonisolated struct ReminderSetting: Codable, Equatable, Sendable {
    var isEnabled: Bool
    var hour: Int
    var minute: Int
}

/// One notification to schedule every day.
nonisolated struct PlannedReminder: Equatable, Sendable {
    let identifier: String
    let chapterID: Int
    let hour: Int
    let minute: Int
    let title: String
    let body: String
}

nonisolated enum ReminderPlanner {
    static let identifierPrefix = "reminder."
    static let maxBodyLength = 178

    static func plan(settings: [ReminderKind: ReminderSetting], library: Library,
                     language: String = "fr") -> [PlannedReminder] {
        ReminderKind.allCases.compactMap { kind in
            guard let setting = settings[kind], setting.isEnabled,
                  let chapter = library.chapter(withID: kind.chapterID),
                  let firstDua = library.duas(in: chapter.id).first
            else { return nil }
            let transliteration = firstDua.transliteration?[language] ?? ""
            let text = transliteration.isEmpty ? firstDua.translation.text(for: language) : transliteration
            return PlannedReminder(
                identifier: identifierPrefix + kind.rawValue,
                chapterID: chapter.id,
                hour: setting.hour,
                minute: setting.minute,
                title: chapter.title.text(for: language),
                body: preview(of: text)
            )
        }
    }

    /// What to show right now for one situation (Shortcuts action).
    static func planNow(chapterID: Int, library: Library, language: String = "fr") -> PlannedReminder? {
        guard let chapter = library.chapter(withID: chapterID),
              let firstDua = library.duas(in: chapterID).first else { return nil }
        let transliteration = firstDua.transliteration?[language] ?? ""
        return PlannedReminder(
            identifier: "now.\(chapterID)", chapterID: chapterID, hour: 0, minute: 0,
            title: chapter.title.text(for: language),
            body: preview(of: transliteration.isEmpty ? firstDua.translation.text(for: language) : transliteration)
        )
    }

    /// Short enough to read on the Lock Screen without opening the app.
    static func preview(of text: String) -> String {
        let flat = text.split(whereSeparator: \.isNewline).joined(separator: " ")
        guard flat.count > maxBodyLength else { return flat }
        return flat.prefix(maxBodyLength).trimmingCharacters(in: .whitespaces) + "…"
    }
}

/// The user's reminder choices, kept on this device.
@Observable
final class ReminderSettingsStore {
    private static let key = "reminderSettings"

    private(set) var settings: [ReminderKind: ReminderSetting]
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let saved = (defaults.data(forKey: Self.key))
            .flatMap { try? JSONDecoder().decode([String: ReminderSetting].self, from: $0) } ?? [:]
        settings = Dictionary(uniqueKeysWithValues: ReminderKind.allCases.map { kind in
            (kind, saved[kind.rawValue]
                ?? ReminderSetting(isEnabled: false, hour: kind.defaultTime.hour, minute: kind.defaultTime.minute))
        })
    }

    func setting(for kind: ReminderKind) -> ReminderSetting {
        settings[kind] ?? ReminderSetting(isEnabled: false, hour: kind.defaultTime.hour, minute: kind.defaultTime.minute)
    }

    func update(_ kind: ReminderKind, to setting: ReminderSetting) {
        settings[kind] = setting
        let encoded = Dictionary(uniqueKeysWithValues: settings.map { ($0.key.rawValue, $0.value) })
        defaults.set(try? JSONEncoder().encode(encoded), forKey: Self.key)
    }
}
