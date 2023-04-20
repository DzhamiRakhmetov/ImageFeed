//
//  ImagesListViewControllerSpy.swift
//  ImageListViewTests
//
//  Created by Джами on 17.04.2023.
//

import Foundation
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    var photos: [Photo]
    
    init(photos: [Photo]) {
        self.photos = photos
    }
    
    func isLike(indexPath: IndexPath, isOn: Bool) {
        
    }
    
    func showLikeAlert(with: Error) {
        
    }
    
    func didReceivePhotosForTableViewAnimatedUpdate(at indexPath: [IndexPath], new array: [ImageFeed.Photo]) {
        
    }
}
