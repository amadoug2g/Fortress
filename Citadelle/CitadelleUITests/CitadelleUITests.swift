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
        tap("chapter-11", in: app)

        XCTAssertTrue(element("dua-1101", in: app).waitForExistence(timeout: 5))
    }

    @MainActor
    func testAChapterShowsEveryDuaForThatSituation() throws {
        let app = launchApp()

        tap("category-priere", in: app)
        tap("chapter-9", in: app)

        for id in ["dua-901", "dua-902", "dua-903"] {
            XCTAssertTrue(element(id, in: app).waitForExistence(timeout: 5), "\(id) is missing")
        }
    }

    @MainActor
    func testSearchingWithoutAccentsFindsTheSituation() throws {
        let app = launchApp()

        search("eternue", in: app)
        tap("result-77", in: app)

        XCTAssertTrue(element("dua-7701", in: app).waitForExistence(timeout: 5))
    }

    @MainActor
    func testSearchWithNoMatchSaysSo() throws {
        let app = launchApp()

        search("ordinateur", in: app)

        XCTAssertTrue(app.staticTexts["Aucun résultat"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testAFavoriteShowsUpInFavoritesUnderItsTheme() throws {
        let app = launchApp()

        tap("category-maison", in: app)
        tap("chapter-11", in: app)
        tap("favorite-1101", in: app)
        goBack(in: app)
        goBack(in: app)
        tap("favorites", in: app)

        XCTAssertTrue(app.staticTexts["Maison et vêtements"].waitForExistence(timeout: 5))
        XCTAssertTrue(element("dua-1101", in: app).waitForExistence(timeout: 5))
    }

    @MainActor
    func testFavoritesStartEmpty() throws {
        let app = launchApp()

        tap("favorites", in: app)

        XCTAssertTrue(app.staticTexts["Aucun favori"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testALongDuaStartsFoldedAndCanBeUnfolded() throws {
        let app = launchApp()

        tap("category-matin-soir", in: app)
        tap("chapter-27", in: app)
        let toggle = element("toggle-2702", in: app)
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        XCTAssertEqual(toggle.value as? String, "Replié")

        toggle.tap()

        XCTAssertEqual(toggle.value as? String, "Déplié")
    }

    // MARK: - Helpers

    @MainActor
    private func goBack(in app: XCUIApplication) {
        let back = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(back.waitForExistence(timeout: 5))
        back.tap()
    }


    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-resetState"]
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
