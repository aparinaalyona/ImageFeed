//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Алена Апарина on 25.12.2025.
//

import XCTest

final class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("alyonaa.malashenko@gmail.com")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("99050999Al")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let feedTable = app.tables.element(boundBy: 0)

        XCTAssertTrue(
            feedTable.waitForExistence(timeout: 10),
            "Экран ленты не загрузился"
        )

        feedTable.swipeUp()

        let topCell = feedTable.cells.element(boundBy: 0)
        XCTAssertTrue(
            topCell.waitForExistence(timeout: 5),
            "Верхняя ячейка не найдена"
        )

        let likeButton = topCell.buttons["No Active"]
        XCTAssertTrue(
            likeButton.waitForExistence(timeout: 5),
            "Кнопка лайка не найдена"
        )
        likeButton.tap()

        let activeLikeButton = topCell.buttons["Active"]
        XCTAssertTrue(
            activeLikeButton.waitForExistence(timeout: 5),
            "Активная кнопка лайка не найдена"
        )
        activeLikeButton.tap()

        topCell.tap()

        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(
            image.waitForExistence(timeout: 10),
        )

        image.pinch(withScale: 3.0, velocity: 1.0)

        image.pinch(withScale: 0.5, velocity: -1.0)

        let backButton = app.buttons["backButton"]
        XCTAssertTrue(
            backButton.waitForExistence(timeout: 5),
        )
        backButton.tap()
    }

    func testProfile() throws {
        let feedTable = app.tables.element(boundBy: 0)
        XCTAssertTrue(
            feedTable.waitForExistence(timeout: 10),
            "Экран ленты не загрузился"
        )

        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(
            profileTab.waitForExistence(timeout: 5),
            "Таб профиля не найден"
        )
        profileTab.tap()

        let fullName = app.staticTexts["Alyona Aparina"]
        let username = app.staticTexts["@alyonabless"]

        XCTAssertTrue(
            fullName.waitForExistence(timeout: 5),
            "Имя пользователя не отображается"
        )
        XCTAssertTrue(
            username.waitForExistence(timeout: 5),
            "Юзернейм не отображается"
        )

        let logoutButton = app.buttons["logoutButton"]
        XCTAssertTrue(
            logoutButton.waitForExistence(timeout: 5),
            "Кнопка логаута не найдена"
        )
        logoutButton.tap()

        let logoutAlert = app.alerts["Пока-пока!"]
        XCTAssertTrue(
            logoutAlert.waitForExistence(timeout: 5),
            "Алерт логаута не появился"
        )
        logoutAlert.buttons["ДА"].tap()

        let loginButton = app.buttons["Authenticate"]
        XCTAssertTrue(
            loginButton.waitForExistence(timeout: 10),
            "Экран авторизации не открылся"
        )
    }

}
