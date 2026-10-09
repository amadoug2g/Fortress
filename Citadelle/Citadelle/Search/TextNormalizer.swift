//
//  TextNormalizer.swift
//  Citadelle
//

import Foundation

/// Puts text in a comparable form so search forgives accents, case and
/// Arabic vowel marks.
nonisolated enum TextNormalizer {
    static func normalize(_ text: String) -> String {
        let folded = text.folding(
            options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive],
            locale: Locale(identifier: "fr_FR")
        )
        var scalars = String.UnicodeScalarView()
        scalars.append(contentsOf: folded.unicodeScalars.filter { !isArabicMark($0) })
        return String(scalars).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Arabic vowel marks (harakat, shadda, sukun...), Quranic annotation
    /// signs and the tatweel stretching character: none change the word.
    private static func isArabicMark(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.value {
        case 0x0610...0x061A, 0x064B...0x065F, 0x0670, 0x06D6...0x06ED, 0x0640:
            true
        default:
            false
        }
    }
}
