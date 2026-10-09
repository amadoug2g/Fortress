//
//  LibraryValidationTests.swift
//  CitadelleTests
//

import Testing
@testable import Citadelle

/// The validator is the safety net for content: it catches data mistakes
/// (a dua pointing to a missing chapter, a missing translation...) before
/// they reach a user.
struct LibraryValidationTests {

    @Test func aConsistentLibraryHasNoIssues() {
        #expect(Fixtures.library().validate() == [])
    }

    @Test func detectsDuplicateIDs() {
        var library = Fixtures.library()
        library.categories.append(library.categories[0])
        library.chapters.append(library.chapters[0])
        library.duas.append(library.duas[0])

        let issues = library.validate()

        #expect(issues.contains(.duplicateCategoryID("maison")))
        #expect(issues.contains(.duplicateChapterID(2)))
        #expect(issues.contains(.duplicateDuaID(12)))
    }

    @Test func detectsBrokenLinks() {
        var library = Fixtures.library()
        library.chapters[0].categoryId = "inconnue"
        library.duas[0].chapterId = 999

        let issues = library.validate()

        #expect(issues.contains(.chapterWithUnknownCategory(chapterID: 2, categoryID: "inconnue")))
        #expect(issues.contains(.duaWithUnknownChapter(duaID: 12, chapterID: 999)))
    }

    @Test func detectsChapterWithoutDuas() {
        var library = Fixtures.library()
        library.duas.removeAll { $0.chapterId == 3 }

        #expect(library.validate().contains(.chapterWithoutDuas(3)))
    }

    @Test func detectsMissingText() {
        var library = Fixtures.library()
        library.duas[0].arabic = "  "
        library.duas[1].translation = ["en": "Praise be to Allah"]
        library.chapters[0].title = ["fr": ""]

        let issues = library.validate()

        #expect(issues.contains(.missingArabic(duaID: 12)))
        #expect(issues.contains(.missingTranslation(duaID: 11, language: "fr")))
        #expect(issues.contains(.missingChapterTitle(chapterID: 2, language: "fr")))
    }

    @Test func detectsInvalidRepeatCount() {
        var library = Fixtures.library()
        library.duas[0].repeatCount = 0

        #expect(library.validate().contains(.invalidRepeatCount(duaID: 12)))
    }
}
