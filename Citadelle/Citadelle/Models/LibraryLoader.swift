//
//  LibraryLoader.swift
//  Citadelle
//

import Foundation

nonisolated enum LibraryLoader {
    static let resourceName = "hisn"

    enum LoadError: Error, Equatable {
        case resourceNotFound(String)
    }

    static func decode(_ data: Data) throws -> Library {
        try JSONDecoder().decode(Library.self, from: data)
    }

    /// Loads the content file shipped inside the app.
    static func loadBundled(from bundle: Bundle = .main) throws -> Library {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw LoadError.resourceNotFound("\(resourceName).json")
        }
        return try decode(Data(contentsOf: url))
    }
}
