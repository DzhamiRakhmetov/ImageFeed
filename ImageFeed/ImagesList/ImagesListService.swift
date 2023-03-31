//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Джами on 19.03.2023.
//

import Foundation
import UIKit

// MARK: - Structs for Decoding

struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let width, height: Int
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    
    struct UrlsResult: Codable {
        let raw, full, regular, small: String
        let thumb: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width, height
        case likes
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}

// MARK: - Structs for Updating UI

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let fullImageURL: String
    let isLiked: Bool
}

struct Liked: Codable {
    let photo: PhotoResult
}

final class ImagesListService {
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    static let shared = ImagesListService()
    private let dateFormatter = ISO8601DateFormatter()
    private let oAuth2TokenStorage = OAuth2TokenStorage.shared
    
    func preparePhoto(_ photoResult: [PhotoResult]) {
        let newPhotos = photoResult.map { item in
            return Photo(id: item.id, size: CGSize(width: item.width, height: item.height), createdAt: dateFormatter.date(from: item.createdAt), welcomeDescription: item.description, thumbImageURL: item.urls.thumb, fullImageURL: item.urls.full, isLiked: item.likedByUser)
        }
        self.photos.append(contentsOf: newPhotos)
        print("Number of photos being appended - \(photoResult.count)")
        print("Number of photos in array - \(photos.count)")
    }
    
    // MARK: - Load next 10 images
    
    func fetchPhotosNextPage(){
        assert(Thread.isMainThread)
        if task != nil {return}
        
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        lastLoadedPage = nextPage
        
        let request = makeRequest(path: "/photos?page=\(nextPage)&&per_page=10")
        let task = urlSession.objectTask(for: request) {[weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else {return}
            switch result {
            case .success(let photoResult):
                self.preparePhoto(photoResult)
                NotificationCenter.default.post(name: ImagesListService.DidChangeNotification, object: self, userInfo: ["photos" : self.photos] )
                self.task = nil
            case .failure(let error):
                self.task = nil
                print(error)
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Likes
    
    func changeLikes(photoID: String, isLike: Bool, _ completion: @escaping(Result<Void, Error>) -> Void){
        
        guard let token = oAuth2TokenStorage.token  else {fatalError("Failed to create Token")}
        let method = isLike ?  "DELETE" : "POST"
        var request = URLRequest.makeHTTPRequest(
            path: "/photos/\(photoID)/like",
            httpMethod: method,
            baseURL: DefaultBaseURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<Liked, Error>)in
            guard let self = self else {return}
            switch result {
            case .success(_):
                if let index = self.photos.firstIndex(where: {$0.id == photoID}) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(id: photo.id, size: photo.size, createdAt: photo.createdAt, welcomeDescription: photo.welcomeDescription, thumbImageURL: photo.thumbImageURL, fullImageURL: photo.fullImageURL, isLiked: !photo.isLiked)
                    self.photos[index] = newPhoto
                }
                completion (.success(()))
            case .failure(let error):
                completion (.failure(error))
            }
        }
        task.resume()
    }
    
    
    private func makeRequest(path: String) -> URLRequest {
        
        guard let url = URL(string: path, relativeTo: DefaultBaseURL) else {fatalError("Failed to create URL for ImagesList")}
        guard let token = oAuth2TokenStorage.token else {fatalError("Failed to create Token")}
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}


