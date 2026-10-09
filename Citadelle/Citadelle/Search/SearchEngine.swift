//
//  SearchEngine.swift
//  Citadelle
//

import Foundation

/// Finds the chapters (situations) matching what the user typed.
nonisolated struct SearchEngine: Sendable {
    private let library: Library
    private let language: String

    init(library: Library, language: String = "fr") {
        self.library = library
        self.language = language
    }

    func search(_ query: String) -> [Chapter] {
        []
    }
}
