//
//  CitadelleApp.swift
//  Citadelle
//
//  Created by Amadou on 09.10.2026.
//

import Foundation
import SwiftUI

@main
struct CitadelleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let library = Result { try LibraryLoader.loadBundled() }
    @State private var favorites: FavoritesStore
    @State private var audioPlayer = AudioPlayer()
    @State private var reminders = ReminderSettingsStore()

    init() {
        let favorites = FavoritesStore()
        // UI tests start from a clean state.
        if ProcessInfo.processInfo.arguments.contains("-resetState") {
            favorites.removeAll()
        }
        _favorites = State(initialValue: favorites)
    }

    var body: some Scene {
        WindowGroup {
            switch library {
            case .success(let library):
                ContentView(library: library)
                    .environment(favorites)
                    .environment(audioPlayer)
                    .environment(reminders)
                    .environment(AppRouter.shared)
            case .failure(let error):
                ContentUnavailableView(
                    "Impossible de charger le contenu",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error.localizedDescription)
                )
            }
        }
    }
}
