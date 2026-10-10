//
//  DuaPresentationTests.swift
//  CitadelleTests
//

import Testing
@testable import Citadelle

struct DuaPresentationTests {

    private func dua(arabic: String, audio: String? = nil) -> Dua {
        Dua(id: 1, chapterId: 1, order: 1, arabic: arabic, translation: ["fr": "…"],
            transliteration: nil, repeatCount: 1, note: nil, source: "Muslim", audio: audio)
    }

    @Test func shortDuasStartOpenLongOnesStartFolded() {
        #expect(!dua(arabic: String(repeating: "ب", count: 100)).startsFolded)
        #expect(dua(arabic: String(repeating: "ب", count: 400)).startsFolded)
    }

    @Test func vowelMarksCountTowardsTheLength() {
        // Each letter carries a vowel mark: 200 visible letters, 400 signs.
        #expect(dua(arabic: String(repeating: "بِ", count: 200)).startsFolded)
    }

    @Test func audioPrefersTheDuaRecordingThenTheChapterOne() {
        let chapter = Chapter(id: 1, categoryId: "c", order: 1, title: ["fr": "x"], keywords: nil,
                              audio: "https://example.org/chapter.mp3")

        #expect(dua(arabic: "ب", audio: "https://example.org/dua.mp3").audioURLs(chapter: chapter).map(\.absoluteString)
                == ["https://example.org/dua.mp3", "https://example.org/chapter.mp3"])
        #expect(dua(arabic: "ب").audioURLs(chapter: chapter).map(\.absoluteString)
                == ["https://example.org/chapter.mp3"])
        #expect(dua(arabic: "ب").audioURLs(chapter: nil).isEmpty)
    }
}
