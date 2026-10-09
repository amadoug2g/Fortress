//
//  LibraryQueryTests.swift
//  CitadelleTests
//

import Testing
@testable import Citadelle

struct LibraryQueryTests {

    private let library = Fixtures.library()

    @Test func categoriesAreSortedByOrder() {
        #expect(library.sortedCategories.map(\.id) == ["matin-soir", "maison"])
    }

    @Test func chaptersOfACategoryAreSortedByOrder() {
        #expect(library.chapters(in: "matin-soir").map(\.id) == [1, 2])
        #expect(library.chapters(in: "maison").map(\.id) == [3])
        #expect(library.chapters(in: "inconnue").isEmpty)
    }

    @Test func duasOfAChapterAreSortedByOrder() {
        #expect(library.duas(in: 1).map(\.id) == [11, 12])
        #expect(library.duas(in: 999).isEmpty)
    }

    @Test func lookupsById() {
        #expect(library.chapter(withID: 3)?.title["fr"] == "En entrant dans la maison")
        #expect(library.chapter(withID: 999) == nil)
        #expect(library.category(withID: "maison")?.icon == "house")
        #expect(library.category(withID: "inconnue") == nil)
    }
}
