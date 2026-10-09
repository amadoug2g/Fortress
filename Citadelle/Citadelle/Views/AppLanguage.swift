//
//  AppLanguage.swift
//  Citadelle
//

/// The language the content is shown in. French only for now.
enum AppLanguage {
    static let content = "fr"
}

/// "1 invocation", "3 invocations".
func countLabel(_ count: Int, singular: String, plural: String) -> String {
    count == 1 ? "1 \(singular)" : "\(count) \(plural)"
}
