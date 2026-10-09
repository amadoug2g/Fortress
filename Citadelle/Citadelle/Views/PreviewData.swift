//
//  PreviewData.swift
//  Citadelle
//

extension Library {
    /// The bundled content, for Xcode previews.
    static var preview: Library {
        (try? LibraryLoader.loadBundled())
            ?? Library(version: 1, isSample: true, categories: [], chapters: [], duas: [])
    }
}
