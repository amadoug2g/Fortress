//
//  DuaCard.swift
//  Citadelle
//

import SwiftUI

struct DuaCard: View {
    let dua: Dua
    /// "2 of 3" when the situation has several duas.
    let position: (index: Int, total: Int)?

    private var language: String { AppLanguage.content }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if position != nil || dua.repeatCount > 1 {
                HStack {
                    if let position {
                        Text("Invocation \(position.index) sur \(position.total)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if dua.repeatCount > 1 {
                        Text("× \(dua.repeatCount)")
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.tint.opacity(0.15), in: Capsule())
                            .accessibilityLabel("À répéter \(dua.repeatCount) fois")
                    }
                }
            }

            Text(dua.arabic)
                .font(.title)
                .lineSpacing(10)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)

            if let transliteration = dua.transliteration?[language] {
                Text(transliteration)
                    .font(.callout)
                    .italic()
                    .foregroundStyle(.secondary)
            }

            if let translation = dua.translation[language], !translation.isEmpty {
                Text(translation)
                    .font(.body)
            } else {
                Text("Traduction française en cours de rédaction.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            if let note = dua.note?[language] {
                Text(note)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Text("Source : \(dua.source)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .textSelection(.enabled)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("dua-\(dua.id)")
    }
}
