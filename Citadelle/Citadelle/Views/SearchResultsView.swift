//
//  SearchResultsView.swift
//  Citadelle
//

import SwiftUI

struct SearchResultsView: View {
    let results: [Chapter]
    let library: Library

    var body: some View {
        if results.isEmpty {
            ContentUnavailableView(
                "Aucun résultat",
                systemImage: "magnifyingglass",
                description: Text("Essayez un autre mot, par exemple « pluie » ou « dormir ».")
            )
        } else {
            List(results) { chapter in
                NavigationLink(value: chapter) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(chapter.title.text(for: AppLanguage.content))
                        if let category = library.category(withID: chapter.categoryId) {
                            Text(category.title.text(for: AppLanguage.content))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .accessibilityIdentifier("result-\(chapter.id)")
            }
        }
    }
}
