//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Джами on 11.04.2023.
//

import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? {get set}
    func viewDidLoad()
    func updateNextPageIfNeeded(forRowAt indexPath: IndexPath)
    func selectLike(indexPath: IndexPath)
    var photos: [Photo] {get}
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    var imagesListServiceObserver: NSObjectProtocol?
    private var imagesListService = ImagesListService.shared
    private(set) var photos: [Photo] = []
    
    init(view: ImagesListViewControllerProtocol) {
        self.view = view
    }
    
    func viewDidLoad(){
        UIBlockingProgressHUD.show()
        setNotificationObserver()
        imagesListService.fetchPhotosNextPage()
    }
    
    func setNotificationObserver() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main) {[weak self] _ in
                guard let self = self else {return}
                self.updateTableViewAnimated()
                UIBlockingProgressHUD.dismiss()
            }
    }
    
    func updateNextPageIfNeeded(forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == imagesListService.photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func selectLike(indexPath: IndexPath) {
        let row = indexPath.row
        let photo = photos[row]
        let id = photo.id
        let isOnLike = !photo.isLiked
        imagesListService.changeLikes(photoID: id, isLike: isOnLike) { [weak self]  result in
            guard let self = self else {return}
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                let isOn = self.photos[row].isLiked
                self.view?.isLike(indexPath: indexPath, isOn: isOn)
            case .failure(let error):
                self.view?.showLikeAlert(with: error)
            }
        }
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            let indexPath = createIndexPaths(from: oldCount, to: newCount)
            view?.didReceivePhotosForTableViewAnimatedUpdate(at: indexPath, new: imagesListService.photos)
        }
    }
    
    private func createIndexPaths(from oldCount: Int, to newCount: Int) -> [IndexPath] {
        return (oldCount..<newCount).map { i in
            IndexPath(row: i, section: 0)
        }
    }
    
    
}
