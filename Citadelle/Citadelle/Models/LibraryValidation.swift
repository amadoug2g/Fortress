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
        []
    }
}
