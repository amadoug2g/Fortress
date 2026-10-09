//
//  LibraryValidation.swift
//  Citadelle
//
//  Catches content mistakes before they reach a user.
//

import Foundation

nonisolated enum LibraryIssue: Hashable, Sendable {
    case duplicateCategoryID(String)
    case duplicateChapterID(Int)
    case duplicateDuaID(Int)
    case chapterWithUnknownCategory(chapterID: Int, categoryID: String)
    case duaWithUnknownChapter(duaID: Int, chapterID: Int)
    case chapterWithoutDuas(Int)
    case missingArabic(duaID: Int)
    case missingTranslation(duaID: Int, language: String)
    case missingChapterTitle(chapterID: Int, language: String)
    case invalidRepeatCount(duaID: Int)
}

nonisolated extension Library {
    /// Every problem found in the content; empty when the content is consistent.
    func validate(requiredLanguage language: String = "fr") -> [LibraryIssue] {
        var issues: [LibraryIssue] = []

        issues += duplicates(in: categories.map(\.id)).map(LibraryIssue.duplicateCategoryID)
        issues += duplicates(in: chapters.map(\.id)).map(LibraryIssue.duplicateChapterID)
        issues += duplicates(in: duas.map(\.id)).map(LibraryIssue.duplicateDuaID)

        let categoryIDs = Set(categories.map(\.id))
        let chapterIDs = Set(chapters.map(\.id))
        let chapterIDsWithDuas = Set(duas.map(\.chapterId))

        for chapter in chapters {
            if !categoryIDs.contains(chapter.categoryId) {
                issues.append(.chapterWithUnknownCategory(chapterID: chapter.id, categoryID: chapter.categoryId))
            }
            if !chapterIDsWithDuas.contains(chapter.id) {
                issues.append(.chapterWithoutDuas(chapter.id))
            }
            if isBlank(chapter.title[language]) {
                issues.append(.missingChapterTitle(chapterID: chapter.id, language: language))
            }
        }

        for dua in duas {
            if !chapterIDs.contains(dua.chapterId) {
                issues.append(.duaWithUnknownChapter(duaID: dua.id, chapterID: dua.chapterId))
            }
            if isBlank(dua.arabic) {
                issues.append(.missingArabic(duaID: dua.id))
            }
            if isBlank(dua.translation[language]) {
                issues.append(.missingTranslation(duaID: dua.id, language: language))
            }
            if dua.repeatCount < 1 {
                issues.append(.invalidRepeatCount(duaID: dua.id))
            }
        }

        return issues
    }

    private func duplicates<ID: Hashable>(in ids: [ID]) -> [ID] {
        var seen = Set<ID>()
        var result: [ID] = []
        for id in ids where !seen.insert(id).inserted && !result.contains(id) {
            result.append(id)
        }
        return result
    }

    private func isBlank(_ text: String?) -> Bool {
        (text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
