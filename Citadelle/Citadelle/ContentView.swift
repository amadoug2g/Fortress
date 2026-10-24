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
    case reminders
}

/// Root screen: categories to browse, replaced by results while searching.
struct ContentView: View {
    let library: Library
    private let searchEngine: SearchEngine
    @State private var query = ""
    @State private var path = NavigationPath()
    @Environment(AppRouter.self) private var router

    init(library: Library) {
        self.library = library
        self.searchEngine = SearchEngine(library: library, language: AppLanguage.content)
    }

    var body: some View {
        NavigationStack(path: $path) {
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
                case .reminders:
                    RemindersView(library: library)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: AppRoute.reminders) {
                        Image(systemName: "bell")
                    }
                    .accessibilityLabel("Rappels")
                    .accessibilityIdentifier("reminders")
                }
            }
            .searchable(
                text: $query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Réveil, pluie, angoisse…"
            )
        }
        .onChange(of: router.pendingChapterID, initial: true) { _, chapterID in
            guard let chapterID, let chapter = library.chapter(withID: chapterID) else { return }
            router.pendingChapterID = nil
            query = ""
            path = NavigationPath()
            path.append(chapter)
        }
    }
}

#Preview {
    ContentView(library: .preview)
        .environment(FavoritesStore())
        .environment(AudioPlayer())
        .environment(AppRouter.shared)
}
