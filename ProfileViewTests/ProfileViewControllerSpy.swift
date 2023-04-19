//
//  ProfileViewControllerSpy.swift
//  ProfileViewTests
//
//  Created by Джами on 07.04.2023.
//

@testable import ImageFeed
import Foundation
import UIKit

final class ProfileViewControllerSpy: UIAlertAction, ProfileViewControllerProtocol {
    
    var presenter: ImageFeed.ProfilePresenterProtocol?
    var setAvatarCalls = false
    
    func updateAvatar() {
        setAvatarCalls = true
    }
    
    func didTapLogOutButton() {
        
    }
    
    func alert(title: String, message: String, action: ((UIAlertAction) -> ())?) {
        
    }
    
    func configureViews() {
        
    }
    
    func setUpGradient() {
        
    }
    
    func configureConstraints() {
        
    }
    
    func updateProfileDetails(profile: ImageFeed.Profile?) {
        
    }
    
    func updateRootViewControler() {
        
    }
}
