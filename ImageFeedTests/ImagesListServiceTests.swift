//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Джами on 21.03.2023.
//

import XCTest
@testable import ImageFeed

final class ImagesListServiceTests: XCTestCase {

    func testExample() throws {
      let service = ImagesListService()
        
        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
            }
        service.fetchPhotosNextPage()
        print("fetchPhotosNextPage called")
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 10)
    }
}
