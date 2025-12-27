//
//  ImagesListViewControllerTests.swift
//  ImageFeed
//
//  Created by Алена Апарина on 25.12.2025.
//
@testable import ImageFeed
import XCTest

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    var fetchPhotosNextPageCalled = false
    var photos: [Photo] = []

    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }

    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    static var didChangeNotification: Notification.Name {
        ImagesListService.didChangeNotification
    }
}

final class ImagesListViewControllerTests: XCTestCase {
    var sut: ImagesListViewController!
    var serviceSpy: ImagesListServiceSpy!

    override func setUp() {
        super.setUp()
        sut = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        serviceSpy = ImagesListServiceSpy()
        sut.loadViewIfNeeded()
        sut.inject(service: serviceSpy)
    }

    override func tearDown() {
        sut = nil
        serviceSpy = nil
        super.tearDown()
    }

    func testViewDidLoadCallsFetchPhotos() {
        XCTAssertTrue(serviceSpy.fetchPhotosNextPageCalled, "После viewDidLoad должен вызваться fetchPhotosNextPage")
    }

    func testPrepareForSeguePassesURL() {
        let indexPath = IndexPath(row: 0, section: 0)
        sut.photos = [
            Photo(
                id: "1",
                size: CGSize(width: 100, height: 100),
                createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "url1",
                largeImageURL: "url1",
                isLiked: false
            )
        ]

        let destinationVC = SingleImageViewController()
        let segue = UIStoryboardSegue(identifier: "ShowSingleImage", source: sut, destination: destinationVC)

        sut.prepare(for: segue, sender: indexPath)

        XCTAssertEqual(destinationVC.fullImageURL, URL(string: "url1"))
    }
}
