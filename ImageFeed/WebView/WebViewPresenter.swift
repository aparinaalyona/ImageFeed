//
//  WebViewPresenterProtocol.swift
//  ImageFeed
//
//  Created by Алена Апарина on 25.12.2025.
//
import Foundation
public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }

    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    private let authHelper: AuthHelperProtocol
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }

    weak var view: WebViewViewControllerProtocol?

    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }

        didUpdateProgressValue(0)
        view?.load(request: request)
    }

    func didUpdateProgressValue(_ newValue: Double) {
        let progress = Float(newValue)
        view?.setProgressValue(progress)
        view?.setProgressHidden(shouldHideProgress(progress))
    }

    func shouldHideProgress(_ value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }

    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
