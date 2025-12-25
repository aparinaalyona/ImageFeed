//
//  ViewController.swift
//  ImageFeed
//
//  Created by Алена Апарина on 06.10.2025.
//

import ProgressHUD
import UIKit

protocol ImagesListServiceProtocol: AnyObject {
    var photos: [Photo] { get }
    static var didChangeNotification: Notification.Name { get }

    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void)
}

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    var photos: [Photo] = []
    var imagesListService: ImagesListServiceProtocol = ImagesListService()
    func inject(service: ImagesListServiceProtocol) {
        imagesListService = service
    }

    private let showSingleImageIdentifier = "ShowSingleImage"

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.dataSource = self
        tableView.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePhotos(_:)),
            name: ImagesListService.didChangeNotification,
            object: nil
        )

        imagesListService.fetchPhotosNextPage()
    }

    @objc func updatePhotos(_ notification: Notification) {
        guard let service = notification.object as? ImagesListService else { return }

        let newCount = service.photos.count - photos.count
        guard newCount > 0 else { return }

        let startIndex = photos.count
        let endIndex = startIndex + newCount - 1

        let indexPaths = (startIndex ... endIndex).map { IndexPath(row: $0, section: 0) }

        photos = service.photos

        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            let photo = photos[indexPath.row]
            viewController.fullImageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        configCell(for: imageListCell, with: indexPath)
        imageListCell.delegate = self

        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]

        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.indicatorType = .activity
            let placeholder = UIImage(named: "placeholder")
            cell.cellImage.kf.setImage(with: url, placeholder: placeholder)
        }

        if let createdAt = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateLabel.text = ""
        }

        let likeImage = photo.isLiked ? UIImage(resource: .active) :
            UIImage(resource: .noActive)
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        let newIsLiked = !photo.isLiked

        DispatchQueue.main.async {
            cell.setIsLiked(newIsLiked)
            self.photos[indexPath.row].isLiked = newIsLiked
        }

        UIBlockingProgressHUD.show()

        imagesListService.changeLike(photoId: photo.id, isLike: newIsLiked) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
            }

            switch result {
            case .success:
                print("Like status changed successfully")

            case let .failure(error):
                print("Failed to change like:", error)

                DispatchQueue.main.async {
                    self.photos[indexPath.row].isLiked = !newIsLiked
                    cell.setIsLiked(!newIsLiked)

                    let alert = UIAlertController(
                        title: "Ошибка",
                        message: "Не удалось поставить лайк: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Ок", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: showSingleImageIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]

        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right

        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom

        return cellHeight
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }

    func configure(service: ImagesListServiceProtocol) {
        imagesListService = service
    }
}
