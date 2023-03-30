//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Джами on 15.03.2023.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ImageSize
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ImageSize: Codable {
    let small: String
    let medium: String
    let large: String
}

final class ProfileImageService {
    
    private (set) var avatarURL: String?
   
    private var task: URLSessionTask?
    private let decoder = JSONDecoder()
    private let urlSession = URLSession.shared
    private var lastUserName: String?
    private let oAuth2TokenStorage = OAuth2TokenStorage.shared
    static let shared = ProfileImageService()
    static let DidChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastUserName == username {return}
        task?.cancel()
        lastUserName = username
        
        let request = makeRequest(username: username)
        let task = urlSession.objectTask(for: request) {[weak self] (result: Result<UserResult, Error>) in
            guard let self = self else {return}
            switch result {
            case .success(let profileImage):
                let profileImageURL = profileImage.profileImage.medium
                self.avatarURL = profileImageURL
                completion(.success(profileImageURL))
                NotificationCenter.default.post(
                    name: ProfileImageService.DidChangeNotification,
                    object: self,
                    userInfo: ["URL": profileImageURL])
                self.task = nil
            case .failure(let error):
                completion(.failure(error))
                self.lastUserName = nil
            }
        }
        self.task = task
        task.resume()
    }
}

extension ProfileImageService {
  
    private func makeRequest(username: String) -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.path = "/users/\(username)"
        guard let url = urlComponents.url(relativeTo: DefaultBaseURL) else {fatalError("Failed to create URL for avatar Image") }
        guard let token = oAuth2TokenStorage.token else {fatalError("Failed to create Token")}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
//    private func object(for request: URLRequest, completion: @escaping(Result<UserResult, Error>) -> Void) -> URLSessionTask {
//
//        return urlSession.data(for: request) { (result: Result<Data, Error>) in
//            switch result {
//            case .success(let data):
//                do {
//                    let object = try self.decoder.decode(UserResult.self, from: data)
//                    completion(.success(object))
//                } catch {
//                    completion(.failure(error))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
}
