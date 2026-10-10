//
//  FavoritesView.swift
//  Citadelle
//

import SwiftUI
import UIKit

/// Favorite duas, grouped by category.
struct FavoritesView: View {
    let library: Library

    @Environment(FavoritesStore.self) private var favorites

    var body: some View {
        let sections = library.favoriteSections(for: favorites.ids)

        Group {
            if sections.isEmpty {
                ContentUnavailableView(
                    "Aucun favori",
                    systemImage: "star",
                    description: Text("Touchez l'étoile d'une invocation pour la retrouver ici.")
                )
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(sections) { section in
                            Label(section.category.title.text(for: AppLanguage.content),
                                  systemImage: section.category.icon)
                                .font(.title3.bold())
                                .padding(.top, 8)
                                .accessibilityAddTraits(.isHeader)

                            ForEach(section.duas) { dua in
                                let chapter = library.chapter(withID: dua.chapterId)
                                VStack(alignment: .leading, spacing: 6) {
                                    if let chapter {
                                        Text(chapter.title.text(for: AppLanguage.content))
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    DuaCard(dua: dua, position: nil, chapter: chapter)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(uiColor: .systemGroupedBackground))
            }
        }
        .navigationTitle("Mes favoris")
        .navigationBarTitleDisplayMode(.inline)
    }
}
