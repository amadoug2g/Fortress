//
//  FavoritesTests.swift
//  CitadelleTests
//

import Foundation
import Testing
@testable import Citadelle

@MainActor
struct FavoritesStoreTests {

    private func makeDefaults() -> UserDefaults {
        UserDefaults(suiteName: "FavoritesStoreTests-\(UUID().uuidString)")!
    }

    @Test func startsEmpty() {
        let store = FavoritesStore(defaults: makeDefaults())

        #expect(store.ids.isEmpty)
        #expect(!store.isFavorite(11))
    }

    @Test func toggleAddsThenRemoves() {
        let store = FavoritesStore(defaults: makeDefaults())

        store.toggle(11)
        #expect(store.isFavorite(11))

        store.toggle(11)
        #expect(!store.isFavorite(11))
    }

    @Test func favoritesSurviveRelaunch() {
        let defaults = makeDefaults()
        FavoritesStore(defaults: defaults).toggle(21)

        #expect(FavoritesStore(defaults: defaults).isFavorite(21))
    }

    @Test func removeAllClearsEverything() {
        let defaults = makeDefaults()
        let store = FavoritesStore(defaults: defaults)
        store.toggle(11)
        store.toggle(21)

        store.removeAll()

        #expect(store.ids.isEmpty)
        #expect(FavoritesStore(defaults: defaults).ids.isEmpty)
    }
}

struct FavoriteSectionsTests {

    private let library = Fixtures.library()

    @Test func groupsFavoritesByCategoryInBookOrder() {
        let sections = library.favoriteSections(for: [31, 21, 12, 11])

        #expect(sections.map(\.category.id) == ["matin-soir", "maison"])
        #expect(sections[0].duas.map(\.id) == [11, 12, 21])
        #expect(sections[1].duas.map(\.id) == [31])
    }

    @Test func ignoresUnknownIDs() {
        #expect(library.favoriteSections(for: [999]).isEmpty)
        #expect(library.favoriteSections(for: []).isEmpty)
    }
}
