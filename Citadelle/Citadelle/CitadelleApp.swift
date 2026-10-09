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
    private let library = Result { try LibraryLoader.loadBundled() }

    var body: some Scene {
        WindowGroup {
            switch library {
            case .success(let library):
                ContentView(library: library)
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
