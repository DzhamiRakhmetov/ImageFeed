//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Джами on 17.03.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let imagesListViewController = SetupControllers.imageVC.viewController
        imagesListViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tab_editorial_active"), selectedImage: nil)
        
        let profileViewController = SetupControllers.profile.viewController
        profileViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tab_profile_active"), selectedImage: nil)
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}

enum SetupControllers {
    case profile
    case imageVC
    
    var viewController: UIViewController {
        switch self {
        case .profile:
            let profileViewController = ProfileViewController()
            let presenter = ProfilePresenter(view: profileViewController)
            profileViewController.presenter =  presenter
            return profileViewController
        case .imageVC:
            let storyBoard = UIStoryboard(name: "Main", bundle: .main)
            let imagesListViewController = storyBoard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
            let presenter = ImagesListPresenter(view: imagesListViewController)
            imagesListViewController.presenter = presenter
            return imagesListViewController
        }
    }
}
