//
//  SituationIntents.swift
//  Citadelle
//
//  Actions offered to the Shortcuts app, so a personal automation (alarm
//  stopped, leaving home, car connected...) can bring up the right dua.
//

import AppIntents
import Foundation

nonisolated struct SituationEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Situation"
    static let defaultQuery = SituationQuery()

    let id: Int
    let title: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
}

nonisolated struct SituationQuery: EntityStringQuery {
    /// Situations people most often tie to a moment of their day.
    private static let suggested = [1, 27, 1027, 28, 10, 11, 95, 96, 13, 15, 25, 69]

    private func all() -> [SituationEntity] {
        guard let library = try? LibraryLoader.loadBundled() else { return [] }
        return library.chapters.map { SituationEntity(id: $0.id, title: $0.title.text(for: "fr")) }
    }

    func entities(for identifiers: [Int]) async throws -> [SituationEntity] {
        all().filter { identifiers.contains($0.id) }
    }

    func entities(matching string: String) async throws -> [SituationEntity] {
        let query = TextNormalizer.normalize(string)
        return all().filter { TextNormalizer.normalize($0.title).contains(query) }
    }

    func suggestedEntities() async throws -> [SituationEntity] {
        let byID = Dictionary(uniqueKeysWithValues: all().map { ($0.id, $0) })
        return Self.suggested.compactMap { byID[$0] }
    }
}

/// "Rappeler une invocation": shows a notification with the situation's
/// first dua, without opening the app. Tapping it opens the situation.
nonisolated struct RemindSituationIntent: AppIntent {
    static let title: LocalizedStringResource = "Rappeler une invocation"
    static let description = IntentDescription("Affiche une notification avec l'invocation à dire.")

    @Parameter(title: "Situation")
    var situation: SituationEntity

    func perform() async throws -> some IntentResult {
        guard let library = try? LibraryLoader.loadBundled(),
              let plan = ReminderPlanner.planNow(chapterID: situation.id, library: library)
        else { return .result() }
        await NotificationService.showNow(title: plan.title, body: plan.body, chapterID: plan.chapterID)
        return .result()
    }
}

/// "Ouvrir une situation": opens the app on that situation.
nonisolated struct OpenSituationIntent: AppIntent {
    static let title: LocalizedStringResource = "Ouvrir une situation"
    static let description = IntentDescription("Ouvre Citadelle sur les invocations d'une situation.")
    static let openAppWhenRun = true

    @Parameter(title: "Situation")
    var situation: SituationEntity

    func perform() async throws -> some IntentResult {
        let id = situation.id
        await MainActor.run { AppRouter.shared.open(chapterID: id) }
        return .result()
    }
}
