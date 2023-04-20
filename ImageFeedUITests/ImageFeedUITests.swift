//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Джами on 05.04.2023.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
private let app = XCUIApplication()
    
    
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["AuthenticateWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 25))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("yan.mohov@mail.ru")
        loginTextField.swipeUp()
        //webView.swipeUp()
        
        let passwordTextFiled = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextFiled.waitForExistence(timeout: 15))
        passwordTextFiled.tap()
        passwordTextFiled.typeText("7ig*pb+mA9f&Y!P")
        webView.swipeUp()
        
        print(app.debugDescription)
        
        let loginButton = webView.descendants(matching: .button).element
        loginButton.tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 15))
        
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        //sleep(15)
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        sleep(5)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        sleep(5)
        cellToLike.buttons["likeButton"].tap()
        sleep(15)
        cellToLike.buttons["likeButton"].tap()
        
        sleep(20)
        
        cellToLike.tap()
        sleep(20)
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["SingleImageBackButton"]
                navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        let nameLabel = app.staticTexts["ProfileNameLabel"]
        let loginNameLabel = app.staticTexts["ProfileLoginNameLabel"]
        XCTAssertTrue(nameLabel.exists)
        XCTAssertTrue(loginNameLabel.exists)
        
        let logOutButton  = app.buttons["ProfileExitButton"]
        logOutButton.tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
