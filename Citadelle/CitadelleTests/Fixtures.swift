//
//  Fixtures.swift
//  CitadelleTests
//

import Foundation
@testable import Citadelle

/// Small hand-built library used by the tests, so they don't depend on the
/// real content (which will change as the full book is imported).
enum Fixtures {
    static func library() -> Library {
        Library(
            version: 1,
            isSample: nil,
            categories: [
                DuaCategory(id: "maison", order: 2, icon: "house", title: ["fr": "Maison"]),
                DuaCategory(id: "matin-soir", order: 1, icon: "sun.horizon", title: ["fr": "Matin et soir"]),
            ],
            chapters: [
                Chapter(
                    id: 2, categoryId: "matin-soir", order: 2,
                    title: ["fr": "Avant de dormir"],
                    keywords: ["fr": ["coucher", "nuit"]]
                ),
                Chapter(
                    id: 1, categoryId: "matin-soir", order: 1,
                    title: ["fr": "Au réveil"],
                    keywords: ["fr": ["se lever", "matin"]]
                ),
                Chapter(
                    id: 3, categoryId: "maison", order: 1,
                    title: ["fr": "En entrant dans la maison"],
                    keywords: nil
                ),
            ],
            duas: [
                Dua(
                    id: 12, chapterId: 1, order: 2,
                    arabic: "سُبْحَانَ اللَّهِ",
                    translation: ["fr": "Gloire à Allah. À dire aussi avant de dormir."],
                    transliteration: nil, repeatCount: 3, note: nil,
                    source: "Muslim", audio: nil
                ),
                Dua(
                    id: 11, chapterId: 1, order: 1,
                    arabic: "الْحَمْدُ لِلَّهِ",
                    translation: ["fr": "Louange à Allah, qui nous a rendu la vie."],
                    transliteration: nil, repeatCount: 1, note: nil,
                    source: "Al-Bukhârî", audio: nil
                ),
                Dua(
                    id: 21, chapterId: 2, order: 1,
                    arabic: "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا",
                    translation: ["fr": "C'est en Ton nom, ô Allah, que je meurs et que je vis."],
                    transliteration: nil, repeatCount: 1, note: nil,
                    source: "Al-Bukhârî", audio: nil
                ),
                Dua(
                    id: 31, chapterId: 3, order: 1,
                    arabic: "بِسْمِ اللَّهِ",
                    translation: ["fr": "Au nom d'Allah, nous sommes entrés."],
                    transliteration: nil, repeatCount: 1, note: nil,
                    source: "Abû Dâwûd", audio: nil
                ),
            ]
        )
    }
}
