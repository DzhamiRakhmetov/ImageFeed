//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Джами on 05.04.2023.
//

import Foundation

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? {get set}
    func logOut()
    func viewDidLoad()
    func setNotificationObserver()
}

final class ProfilePresenter: ProfilePresenterProtocol  {
    weak var view: ProfileViewControllerProtocol?
    var profileImageServiceObserver: NSObjectProtocol?
    private var authToken = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private var profileImageService = ProfileImageService.shared
    
    init(view: ProfileViewControllerProtocol) {
        self.view = view
    }
    
     func viewDidLoad() {
        view?.configureViews()
        view?.configureConstraints()
        view?.setUpGradient()
        view?.updateProfileDetails(profile: profileService.profile)
        setNotificationObserver()
    }
    // MARK: - LogOut
    
     func logOut(){
         //...
         view?.alert(title: "Пока, пока!", message: "Уверены что хотите выйти", action: { [weak self] _ in
             self?.authToken.token = nil
             WebViewViewController.clean()
             self?.view?.updateRootViewControler()
         })
    }
    
    func setNotificationObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.DidChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self?.view  else { return }
                self.updateAvatar()
            }
        guard let view = view else {return}
        view.updateAvatar()
    }
}
