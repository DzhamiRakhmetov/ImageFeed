//
//  ImageListPresenterSpy.swift
//  ImageListViewTests
//
//  Created by Джами on 16.04.2023.
//

@testable import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    
    var photos: [ImageFeed.Photo] = []
    var view: ImageFeed.ImagesListViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var didFetchPhotosCalled: Bool = false
    var updateNextPageIfNeededCalled: Bool = false
    func selectLike(indexPath: IndexPath) {}
    
//    var imagesListService: ImagesListService
    
  
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updateNextPageIfNeeded(forRowAt indexPath: IndexPath) {
         updateNextPageIfNeededCalled = true
        //fetchPhotosNextPage()
    }
    
//    func fetchPhotosNextPage() {
//            didFetchPhotosCalled = true
//        }
}
