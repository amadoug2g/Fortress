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
        let title = category.title.text(for: AppLanguage.content)

        List {
            Section {
                ForEach(library.chapters(in: category.id)) { chapter in
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
            } header: {
                // The full title, never cut, even when it is long.
                Label(title, systemImage: category.icon)
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                    .textCase(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 4)
                    .accessibilityAddTraits(.isHeader)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
