//
//  ProfileViewTests.swift
//  ProfileViewTests
//
//  Created by Джами on 06.04.2023.
//
@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad(){
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testProfileViewCallsLogout() {
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        presenter.logOut()
        
        XCTAssertTrue(presenter.logOutCalled)
    }
}
