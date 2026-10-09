//
//  TextNormalizerTests.swift
//  CitadelleTests
//

import Testing
@testable import Citadelle

struct TextNormalizerTests {

    @Test(arguments: [
        ("Réveil", "reveil"),
        ("ÉTERNUER", "eternuer"),
        ("  Angoisse  ", "angoisse"),
        ("Dâwûd", "dawud"),
    ])
    func latinTextIgnoresCaseAccentsAndSurroundingSpaces(input: String, expected: String) {
        #expect(TextNormalizer.normalize(input) == expected)
    }

    @Test func arabicTextIgnoresVowelMarks() {
        #expect(TextNormalizer.normalize("الْحَمْدُ لِلَّهِ") == TextNormalizer.normalize("الحمد لله"))
    }

    @Test func arabicTextIgnoresTatweel() {
        #expect(TextNormalizer.normalize("اللـــه") == TextNormalizer.normalize("الله"))
    }
}
