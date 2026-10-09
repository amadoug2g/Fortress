//
//  SearchEngineTests.swift
//  CitadelleTests
//

import Testing
@testable import Citadelle

struct SearchEngineTests {

    private let engine = SearchEngine(library: Fixtures.library())

    @Test(arguments: ["", "   "])
    func blankQueryReturnsNothing(query: String) {
        #expect(engine.search(query).isEmpty)
    }

    @Test func findsChapterByTitleWithoutTypingAccents() {
        #expect(engine.search("reveil").map(\.id) == [1])
    }

    @Test func findsChapterByKeyword() {
        #expect(engine.search("coucher").map(\.id) == [2])
    }

    @Test func findsChapterByWordsInsideItsTranslations() {
        #expect(engine.search("je meurs").map(\.id) == [2])
    }

    @Test func findsChapterByArabicWithoutVowelMarks() {
        #expect(engine.search("بسم").map(\.id) == [3])
    }

    @Test func everyWordMustMatch() {
        #expect(engine.search("maison entrant").map(\.id) == [3])
        #expect(engine.search("maison dormir").isEmpty)
    }

    @Test func findsEveryChapterSharingAWord() {
        #expect(Set(engine.search("allah").map(\.id)) == [1, 2, 3])
    }

    @Test func titleMatchesRankBeforeTextMatches() {
        // "dormir" is in chapter 2's title but only in a translation of chapter 1,
        // so chapter 2 comes first even though chapter 1 is earlier in the book.
        #expect(engine.search("dormir").map(\.id) == [2, 1])
    }

    @Test func unknownWordReturnsNothing() {
        #expect(engine.search("ordinateur").isEmpty)
    }
}
