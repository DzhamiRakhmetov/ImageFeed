//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Джами on 21.02.2023.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()
    private let tokenStorage = OAuth2TokenStorage.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private (set) var authToken: String? {
        get {
            return tokenStorage.token
        }
        set {
            tokenStorage.token = newValue
        }
    }
    
    func fetchAuthToken(_ code: String, completion: @escaping(Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        let request = authTokenRequest(code: code)
        let task = urlSession.objectTask(for: request) {(result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                completion(.success(authToken))
                self.task = nil
            case .failure(let error):
                completion(.failure(error))
                self.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
}

private func authTokenRequest(code: String) -> URLRequest {
    URLRequest.makeHTTPRequest(
        path: "/oauth/token"
        + "?client_id=\(AccessKey)"
        + "&&client_secret=\(SecretKey)"
        + "&&redirect_uri=\(RedirectURI)"
        + "&&code=\(code)"
        + "&&grant_type=authorization_code",
        httpMethod: "POST",
        baseURL: URL(string: "https://unsplash.com")!
    )}

// MARK: - Decoding

struct OAuthTokenResponseBody: Decodable {
    let accessToken, tokenType, scope: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}


//extension OAuth2Service {
//    private func object(for request: URLRequest, completion: @escaping(Result<OAuthTokenResponseBody, Error>) -> Void) -> URLSessionTask {
//        
//        return urlSession.data(for: request) {(result: Result<Data, Error>) in
//            switch result {
//            case .success(let data):
//                do {
//                    let object = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
//                    completion(.success(object))
//                } catch {
//                    completion(.failure(error))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//}

// MARK: - HTTP Request

extension URLRequest {
    static func makeHTTPRequest(path: String, httpMethod: String, baseURL: URL = DefaultBaseURL) -> URLRequest {
        guard let url = URL(string: path, relativeTo: baseURL) else { fatalError("Invalid URL")}
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        return request
    }
}






//extension URLSession {
//    func data(for request: URLRequest, complition: @escaping(Result<Data, Error>) -> Void) -> URLSessionTask {
//
//        let fulfillCompletion: (Result<Data, Error>) -> Void = { result in
//            DispatchQueue.main.async {
//                complition(result)
//            }
//        }
//
//        let task = dataTask(with: request) { data, response, error in
//            if let data = data,
//               let response = response,
//               let statusCode = (response as? HTTPURLResponse)?.statusCode
//            {
//
//                if 200 ..< 300 ~= statusCode {
//                    fulfillCompletion(.success(data))
//                } else {
//                    fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
//                }
//            } else if let error = error {
//                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
//            } else {
//                fulfillCompletion(.failure(NetworkError.urlSessionError))
//            }
//        }
//        task.resume()
//        return task
//    }
//}


