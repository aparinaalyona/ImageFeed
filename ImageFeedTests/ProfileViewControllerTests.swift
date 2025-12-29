//
//  ProfileViewControllerTests.swift
//  ImageFeed
//
//  Created by Алена Апарина on 25.12.2025.
//

import XCTest
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var logoutCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func logout() {
        logoutCalled = true
    }
}

final class ProfileViewControllerTests: XCTestCase {

    var sut: ProfileViewController!
    var presenterSpy: ProfilePresenterSpy!

    override func setUp() {
        super.setUp()
        sut = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController
        presenterSpy = ProfilePresenterSpy()
        sut.loadViewIfNeeded()
        sut.configure(presenterSpy)
    }

    override func tearDown() {
        sut = nil
        presenterSpy = nil
        super.tearDown()
    }

    func testViewDidLoadCallsPresenter() {
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }

    func testLogoutButtonShowsAlert() {
        sut.perform(#selector(ProfileViewController.didTapButton))

        let expectation = XCTestExpectation(description: "Alert presented")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.sut.presentedViewController is UIAlertController)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
