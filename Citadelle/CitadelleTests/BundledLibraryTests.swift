//
//  BundledLibraryTests.swift
//  CitadelleTests
//

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

    @Test func everyCategoryHasAtLeastOneChapter() throws {
        let library = try LibraryLoader.loadBundled()

        for category in library.categories {
            #expect(!library.chapters(in: category.id).isEmpty, "Empty category: \(category.id)")
        }
    }
}
