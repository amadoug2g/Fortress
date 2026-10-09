//
//  ChapterListView.swift
//  Citadelle
//

import SwiftUI

/// The situations of one category.
struct ChapterListView: View {
    let category: DuaCategory
    let library: Library

    var body: some View {
        List(library.chapters(in: category.id)) { chapter in
            NavigationLink(value: chapter) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(chapter.title.text(for: AppLanguage.content))
                    Text(countLabel(
                        library.duas(in: chapter.id).count,
                        singular: "invocation",
                        plural: "invocations"
                    ))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
            .accessibilityIdentifier("chapter-\(chapter.id)")
        }
        .navigationTitle(category.title.text(for: AppLanguage.content))
    }
}
