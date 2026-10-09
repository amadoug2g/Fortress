//
//  LibraryDecodingTests.swift
//  CitadelleTests
//

import Foundation
import Testing
@testable import Citadelle

struct LibraryDecodingTests {

    private let minimalJSON = """
    {
      "version": 1,
      "categories": [
        { "id": "maison", "order": 1, "icon": "house", "title": { "fr": "Maison" } }
      ],
      "chapters": [
        { "id": 4, "categoryId": "maison", "order": 1, "title": { "fr": "En entrant dans la maison" } }
      ],
      "duas": [
        {
          "id": 7, "chapterId": 4, "order": 1,
          "arabic": "بِسْمِ اللَّهِ",
          "translation": { "fr": "Au nom d'Allah." },
          "repeatCount": 1,
          "source": "Abû Dâwûd"
        }
      ]
    }
    """

    @Test func decodesAMinimalLibrary() throws {
        let library = try LibraryLoader.decode(Data(minimalJSON.utf8))

        #expect(library.version == 1)
        #expect(library.categories.map(\.id) == ["maison"])
        #expect(library.chapters.map(\.id) == [4])
        #expect(library.duas.first?.arabic == "بِسْمِ اللَّهِ")
        #expect(library.duas.first?.translation["fr"] == "Au nom d'Allah.")
    }

    @Test func optionalFieldsMayBeMissing() throws {
        let dua = try #require(try LibraryLoader.decode(Data(minimalJSON.utf8)).duas.first)

        #expect(dua.transliteration == nil)
        #expect(dua.note == nil)
        #expect(dua.audio == nil)
    }

    @Test func versionTwoFieldsAreReadWhenPresent() throws {
        let json = minimalJSON.replacingOccurrences(
            of: "\"source\": \"Abû Dâwûd\"",
            with: "\"source\": \"Abû Dâwûd\", \"transliteration\": { \"fr\": \"Bismillâh\" }, \"audio\": \"dua_007.m4a\""
        )
        let dua = try #require(try LibraryLoader.decode(Data(json.utf8)).duas.first)

        #expect(dua.transliteration?["fr"] == "Bismillâh")
        #expect(dua.audio == "dua_007.m4a")
    }

    @Test func malformedDataThrows() {
        #expect(throws: (any Error).self) {
            try LibraryLoader.decode(Data("{ \"version\": 1 }".utf8))
        }
    }

    @Test func localizedTextFallsBackToFrenchThenAnyLanguage() {
        let both: LocalizedText = ["fr": "Maison", "en": "Home"]
        let englishOnly: LocalizedText = ["en": "Home"]
        let empty: LocalizedText = [:]

        #expect(both.text(for: "en") == "Home")
        #expect(both.text(for: "de") == "Maison")
        #expect(englishOnly.text(for: "fr") == "Home")
        #expect(empty.text(for: "fr") == "")
    }
}
