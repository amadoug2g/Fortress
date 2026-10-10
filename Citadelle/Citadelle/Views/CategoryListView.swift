//
//  CategoryListView.swift
//  Citadelle
//

import SwiftUI

struct CategoryListView: View {
    let library: Library

    @Environment(FavoritesStore.self) private var favorites

    var body: some View {
        List {
            if library.isSample == true {
                Section {
                    Label(
                        "Contenu d'exemple : quelques invocations seulement, en attendant le livre complet.",
                        systemImage: "info.circle"
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }

            Section {
                NavigationLink(value: AppRoute.favorites) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Mes favoris")
                                .font(.headline)
                            Text(countLabel(favorites.ids.count, singular: "invocation", plural: "invocations"))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                    }
                }
                .accessibilityIdentifier("favorites")
            }

            Section {
                ForEach(library.sortedCategories) { category in
                    NavigationLink(value: category) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(category.title.text(for: AppLanguage.content))
                                    .font(.headline)
                                Text(countLabel(
                                    library.chapters(in: category.id).count,
                                    singular: "situation",
                                    plural: "situations"
                                ))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: category.icon)
                                .foregroundStyle(.tint)
                        }
                    }
                    .accessibilityIdentifier("category-\(category.id)")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CategoryListView(library: .preview)
    }
    .environment(FavoritesStore())
}
