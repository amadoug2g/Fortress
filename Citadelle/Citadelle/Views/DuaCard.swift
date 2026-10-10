//
//  DuaCard.swift
//  Citadelle
//

import SwiftUI
import UIKit

struct DuaCard: View {
    let dua: Dua
    /// "2 of 3" when the situation has several duas.
    let position: (index: Int, total: Int)?
    /// The dua's situation, for the fallback recording.
    let chapter: Chapter?

    @Environment(FavoritesStore.self) private var favorites
    @Environment(AudioPlayer.self) private var audio
    @State private var isFolded: Bool

    private var language: String { AppLanguage.content }

    init(dua: Dua, position: (index: Int, total: Int)?, chapter: Chapter?) {
        self.dua = dua
        self.position = position
        self.chapter = chapter
        _isFolded = State(initialValue: dua.startsFolded)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            Text(dua.arabic)
                .font(.title)
                .lineSpacing(10)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineLimit(isFolded ? 2 : nil)

            if !isFolded, let transliteration = dua.transliteration?[language] {
                Text(transliteration)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Text(dua.translation.text(for: language))
                .font(.body)
                .lineLimit(isFolded ? 2 : nil)

            if !isFolded {
                if let note = dua.note?[language] {
                    Text(note)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Text("Source : \(dua.source)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: cardShape)
        .overlay(cardShape.strokeBorder(Color(uiColor: .separator), lineWidth: 1))
        .textSelection(.enabled)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("dua-\(dua.id)")
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
    }

    private var header: some View {
        HStack(spacing: 4) {
            if let position {
                Text("\(position.index)/\(position.total)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Invocation \(position.index) sur \(position.total)")
            }
            if dua.repeatCount > 1 {
                Text("× \(dua.repeatCount)")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.tint.opacity(0.15), in: Capsule())
                    .accessibilityLabel("À répéter \(dua.repeatCount) fois")
            }

            Spacer()

            playButton
            favoriteButton
            foldButton
        }
    }

    private var playButton: some View {
        let isPlaying = audio.playingID == dua.id
        return Button {
            audio.toggle(id: dua.id, urls: dua.audioURLs(chapter: chapter))
        } label: {
            Group {
                if isPlaying && audio.isLoading {
                    ProgressView()
                } else {
                    Image(systemName: isPlaying ? "stop.circle.fill"
                          : audio.failedID == dua.id ? "exclamationmark.circle" : "play.circle")
                        .font(.title3)
                }
            }
            .frame(width: 36, height: 36)
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(isPlaying ? "Arrêter l'écoute" : "Écouter en arabe")
        .accessibilityIdentifier("play-\(dua.id)")
    }

    private var favoriteButton: some View {
        let isFavorite = favorites.isFavorite(dua.id)
        return Button {
            favorites.toggle(dua.id)
        } label: {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .font(.title3)
                .foregroundStyle(isFavorite ? Color.yellow : Color.accentColor)
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(isFavorite ? "Retirer des favoris" : "Ajouter aux favoris")
        .accessibilityIdentifier("favorite-\(dua.id)")
    }

    private var foldButton: some View {
        Button {
            withAnimation(.smooth(duration: 0.25)) { isFolded.toggle() }
        } label: {
            Image(systemName: "chevron.down")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .rotationEffect(.degrees(isFolded ? 0 : 180))
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(isFolded ? "Déplier" : "Replier")
        .accessibilityValue(isFolded ? "Replié" : "Déplié")
        .accessibilityIdentifier("toggle-\(dua.id)")
    }
}
