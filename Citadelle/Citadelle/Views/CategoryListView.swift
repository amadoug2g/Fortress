//
//  CategoryListView.swift
//  Citadelle
//

import SwiftUI

struct CategoryListView: View {
    let library: Library

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
}
