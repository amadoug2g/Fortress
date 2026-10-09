//
//  CitadelleUITests.swift
//  CitadelleUITests
//
//  Created by Amadou on 09.10.2026.
//

import XCTest

/// Walks through the app like a user would, on the bundled sample content.
final class CitadelleUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testBrowsingFromACategoryToADua() throws {
        let app = launchApp()

        tap("category-maison", in: app)
        tap("chapter-4", in: app)

        XCTAssertTrue(element("dua-4", in: app).waitForExistence(timeout: 5))
    }

    @MainActor
    func testAChapterShowsEveryDuaForThatSituation() throws {
        let app = launchApp()

        tap("category-quotidien", in: app)
        tap("chapter-9", in: app)

        for id in ["dua-10", "dua-11", "dua-12"] {
            XCTAssertTrue(element(id, in: app).waitForExistence(timeout: 5), "\(id) is missing")
        }
    }

    @MainActor
    func testSearchingWithoutAccentsFindsTheSituation() throws {
        let app = launchApp()

        search("eternue", in: app)
        tap("result-9", in: app)

        XCTAssertTrue(element("dua-10", in: app).waitForExistence(timeout: 5))
    }

    @MainActor
    func testSearchWithNoMatchSaysSo() throws {
        let app = launchApp()

        search("ordinateur", in: app)

        XCTAssertTrue(app.staticTexts["Aucun résultat"].waitForExistence(timeout: 5))
    }

    // MARK: - Helpers

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }

    @MainActor
    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    @MainActor
    private func tap(_ identifier: String, in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        let target = element(identifier, in: app)
        XCTAssertTrue(target.waitForExistence(timeout: 10), "\(identifier) not found", file: file, line: line)
        target.tap()
    }

    @MainActor
    private func search(_ text: String, in app: XCUIApplication) {
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 10), "Search field not found")
        field.tap()
        field.typeText(text)
    }
}
