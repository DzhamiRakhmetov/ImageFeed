//
//  ProfileViewPresenterSpy.swift
//  ProfileViewTests
//
//  Created by Джами on 06.04.2023.
//
@testable import ImageFeed
import Foundation

final class ProfileViewPresenterSpy: ProfilePresenterProtocol {
    var view: ImageFeed.ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var logOutCalled: Bool = false
    
    func setNotificationObserver() {
        
    }
    
    func viewDidLoad(){
        viewDidLoadCalled = true
    }
    
    func logOut() {
        logOutCalled = true
    }
}
