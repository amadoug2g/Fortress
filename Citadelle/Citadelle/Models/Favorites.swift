//
//  Favorites.swift
//  Citadelle
//

import Foundation
import Observation

/// Favorite duas, kept on this device.
@Observable
final class FavoritesStore {
    private static let key = "favoriteDuaIDs"

    private(set) var ids: Set<Int>
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        ids = Set(defaults.array(forKey: Self.key) as? [Int] ?? [])
    }

    func isFavorite(_ id: Int) -> Bool {
        ids.contains(id)
    }

    func toggle(_ id: Int) {
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        save()
    }

    func removeAll() {
        ids.removeAll()
        save()
    }

    private func save() {
        defaults.set(ids.sorted(), forKey: Self.key)
    }
}

nonisolated struct FavoriteSection: Identifiable, Sendable {
    let category: DuaCategory
    let duas: [Dua]

    var id: String { category.id }
}

nonisolated extension Library {
    /// Favorite duas grouped by category, in book order.
    func favoriteSections(for ids: Set<Int>) -> [FavoriteSection] {
        guard !ids.isEmpty else { return [] }
        return sortedCategories.compactMap { category in
            let matching = chapters(in: category.id)
                .flatMap { self.duas(in: $0.id) }
                .filter { ids.contains($0.id) }
            return matching.isEmpty ? nil : FavoriteSection(category: category, duas: matching)
        }
    }
}
