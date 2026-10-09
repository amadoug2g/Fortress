//
//  ChapterDetailView.swift
//  Citadelle
//

import SwiftUI

/// Everything to say in one situation.
struct ChapterDetailView: View {
    let chapter: Chapter
    let library: Library

    var body: some View {
        let duas = library.duas(in: chapter.id)
        let title = chapter.title.text(for: AppLanguage.content)

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)

                ForEach(Array(duas.enumerated()), id: \.element.id) { index, dua in
                    DuaCard(dua: dua, position: duas.count > 1 ? (index: index + 1, total: duas.count) : nil)
                }
            }
            .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let library = Library.preview
    NavigationStack {
        if let chapter = library.chapters.first {
            ChapterDetailView(chapter: chapter, library: library)
        }
    }
}
