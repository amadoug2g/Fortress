//
//  DuaPresentation.swift
//  Citadelle
//

import Foundation

nonisolated extension Dua {
    /// Arabic length above which a card starts folded, so long passages
    /// (Ayat al-Kursi, long supplications) don't bury the next ones.
    static let foldThreshold = 280

    /// Counted in Unicode scalars: Swift's `count` merges each letter with
    /// its vowel marks, which would make vocalised text look half as long.
    var startsFolded: Bool {
        arabic.unicodeScalars.count > Self.foldThreshold
    }

    /// Recordings to try in order: this dua's own, then its situation's.
    func audioURLs(chapter: Chapter?) -> [URL] {
        [audio, chapter?.audio].compactMap { $0 }.compactMap(URL.init(string:))
    }
}
