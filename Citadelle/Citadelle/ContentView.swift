//
//  ContentView.swift
//  Citadelle
//
//  Created by Amadou on 09.10.2026.
//

import Foundation
import SwiftUI

/// Destinations that are not content values.
nonisolated enum AppRoute: Hashable {
    case favorites
}

/// Root screen: categories to browse, replaced by results while searching.
struct ContentView: View {
    let library: Library
    private let searchEngine: SearchEngine
    @State private var query = ""

    init(library: Library) {
        self.library = library
        self.searchEngine = SearchEngine(library: library, language: AppLanguage.content)
    }

    var body: some View {
        NavigationStack {
            Group {
                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    CategoryListView(library: library)
                } else {
                    SearchResultsView(results: searchEngine.search(query), library: library)
                }
            }
            .navigationTitle("Citadelle")
            .navigationDestination(for: DuaCategory.self) { category in
                ChapterListView(category: category, library: library)
            }
            .navigationDestination(for: Chapter.self) { chapter in
                ChapterDetailView(chapter: chapter, library: library)
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .favorites:
                    FavoritesView(library: library)
                }
            }
            .searchable(
                text: $query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Réveil, pluie, angoisse…"
            )
        }
    }
}

#Preview {
    ContentView(library: .preview)
        .environment(FavoritesStore())
        .environment(AudioPlayer())
}
