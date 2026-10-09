//
//  Library.swift
//  Citadelle
//
//  The content of the book: categories (shelves) hold chapters (situations),
//  and each chapter holds one or more duas.
//

import Foundation

/// Text in several languages, keyed by language code ("fr", "en"...).
typealias LocalizedText = [String: String]

nonisolated extension Dictionary where Key == String, Value == String {
    /// The text in `language`, falling back to French, then to any language.
    func text(for language: String) -> String {
        ""
    }
}

nonisolated struct Library: Codable, Hashable, Sendable {
    var version: Int
    /// True while the app ships placeholder content instead of the full book.
    var isSample: Bool?
    var categories: [DuaCategory]
    var chapters: [Chapter]
    var duas: [Dua]
}

nonisolated struct DuaCategory: Codable, Hashable, Identifiable, Sendable {
    var id: String
    var order: Int
    /// SF Symbol name.
    var icon: String
    var title: LocalizedText
}

nonisolated struct Chapter: Codable, Hashable, Identifiable, Sendable {
    var id: Int
    var categoryId: String
    var order: Int
    var title: LocalizedText
    /// Extra words people might search with, per language.
    var keywords: [String: [String]]?
}

nonisolated struct Dua: Codable, Hashable, Identifiable, Sendable {
    var id: Int
    var chapterId: Int
    var order: Int
    var arabic: String
    var translation: LocalizedText
    /// Arabic pronunciation written with the reader's alphabet (v2).
    var transliteration: LocalizedText?
    var repeatCount: Int
    var note: LocalizedText?
    var source: String
    /// Audio file name in the app bundle (v2).
    var audio: String?
}

// MARK: - Queries

nonisolated extension Library {
    var sortedCategories: [DuaCategory] {
        []
    }

    func chapters(in categoryID: String) -> [Chapter] {
        []
    }

    func duas(in chapterID: Int) -> [Dua] {
        []
    }

    func chapter(withID id: Int) -> Chapter? {
        nil
    }

    func category(withID id: String) -> DuaCategory? {
        nil
    }
}
