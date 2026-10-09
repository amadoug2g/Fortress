//
//  BundledLibraryTests.swift
//  CitadelleTests
//

import Foundation
import Testing
@testable import Citadelle

/// Checks the content file actually shipped inside the app.
struct BundledLibraryTests {

    @Test func bundledLibraryLoads() throws {
        let library = try LibraryLoader.loadBundled()

        #expect(!library.categories.isEmpty)
        #expect(!library.chapters.isEmpty)
        #expect(!library.duas.isEmpty)
    }

    @Test func bundledLibraryHasNoIssues() throws {
        let issues = try LibraryLoader.loadBundled().validate()

        #expect(issues == [], "Content problems: \(issues)")
    }

    @Test func bundledLibraryIsTheWholeBook() throws {
        let library = try LibraryLoader.loadBundled()
        let chapterIDs = Set(library.chapters.map(\.id))

        #expect(library.isSample != true)
        #expect(library.categories.count == 11)
        #expect(chapterIDs.isSuperset(of: 1...132), "Missing: \(Set(1...132).subtracting(chapterIDs).sorted())")
        #expect(library.chapters.count == 133)
        #expect(library.duas.count >= 300)
    }

    @Test func morningAndEveningRemembrancesAreSeparateSituations() throws {
        let library = try LibraryLoader.loadBundled()
        let morning = try #require(library.chapter(withID: 27))
        let evening = try #require(library.chapter(withID: 1027))

        #expect(morning.categoryId == evening.categoryId)
        #expect(library.duas(in: 27).count > 20)
        #expect(library.duas(in: 1027).count > 20)
    }

    @Test func everyDuaShowsWhereItComesFrom() throws {
        let library = try LibraryLoader.loadBundled()
        let withoutSource = library.duas.filter { $0.source.trimmingCharacters(in: .whitespaces).isEmpty }

        #expect(withoutSource.isEmpty, "No source: \(withoutSource.map(\.id))")
    }

    @Test func everyCategoryHasAtLeastOneChapter() throws {
        let library = try LibraryLoader.loadBundled()

        for category in library.categories {
            #expect(!library.chapters(in: category.id).isEmpty, "Empty category: \(category.id)")
        }
    }
}
