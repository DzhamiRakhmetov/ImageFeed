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
        let storyBoard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyBoard.instantiateViewController(withIdentifier: "ImagesListViewController")
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tab_profile_active"), selectedImage: nil)
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
