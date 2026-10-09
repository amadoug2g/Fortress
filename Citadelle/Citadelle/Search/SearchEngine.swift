//
//  SearchEngine.swift
//  Citadelle
//

import Foundation

/// Finds the chapters (situations) matching what the user typed.
///
/// Every word of the query must appear somewhere in the chapter (title,
/// keywords, or the text of one of its duas). Chapters whose title matches
/// come first, then keyword matches, then text matches; ties keep book order.
nonisolated struct SearchEngine: Sendable {
    private struct Entry: Sendable {
        let chapter: Chapter
        let position: Int
        let title: String
        let keywords: String
        let text: String
    }

    private let entries: [Entry]

    init(library: Library, language: String = "fr") {
        var entries: [Entry] = []
        for category in library.sortedCategories {
            for chapter in library.chapters(in: category.id) {
                let duaTexts = library.duas(in: chapter.id).flatMap { dua in
                    [
                        dua.arabic,
                        dua.translation.text(for: language),
                        dua.transliteration?[language] ?? "",
                    ]
                }
                entries.append(Entry(
                    chapter: chapter,
                    position: entries.count,
                    title: TextNormalizer.normalize(chapter.title.text(for: language)),
                    keywords: TextNormalizer.normalize((chapter.keywords?[language] ?? []).joined(separator: " ")),
                    text: TextNormalizer.normalize(duaTexts.joined(separator: " "))
                ))
            }
        }
        self.entries = entries
    }

    func search(_ query: String) -> [Chapter] {
        let words = TextNormalizer.normalize(query)
            .split(whereSeparator: \.isWhitespace)
            .map(String.init)
        guard !words.isEmpty else { return [] }

        let scored: [(entry: Entry, score: Int)] = entries.compactMap { entry in
            var score = 0
            for word in words {
                if entry.title.contains(word) {
                    score += 3
                } else if entry.keywords.contains(word) {
                    score += 2
                } else if entry.text.contains(word) {
                    score += 1
                } else {
                    return nil
                }
            }
            return (entry, score)
        }

        return scored
            .sorted { $0.score != $1.score ? $0.score > $1.score : $0.entry.position < $1.entry.position }
            .map { $0.entry.chapter }
    }
}
