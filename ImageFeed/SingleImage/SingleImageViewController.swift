//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Алена Апарина on 16.10.2025.
//

import Kingfisher
import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage?
    var fullImageURL: URL?

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var shareButton: UIButton!
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image else { return }

        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(share, animated: true)
    }

    override func viewDidLoad() {
            super.viewDidLoad()

            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 3.0

            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true

            if let url = fullImageURL {
                loadImage(from: url)
            } else if let image {
                imageView.image = image
                rescaleAndCenterImage(image: image)
            }
        }

        private func loadImage(from url: URL) {
            UIBlockingProgressHUD.show()

            imageView.kf.setImage(with: url) { [weak self] result in
                guard let self else { return }

                UIBlockingProgressHUD.dismiss()

                switch result {
                case .success(let value):
                    self.image = value.image
                    self.imageView.image = value.image

                    self.rescaleAndCenterImage(image: value.image)

                case .failure:
                    self.showError(url: url)
                }
            }
        }

        private func showError(url: URL) {
            let alert = UIAlertController(
                title: "Что-то пошло не так",
                message: "Попробовать ещё раз?",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))

            alert.addAction(UIAlertAction(title: "Повторить", style: .default) { _ in
                self.loadImage(from: url)
            })

            present(alert, animated: true)
        }

        private func rescaleAndCenterImage(image: UIImage) {
            scrollView.layoutIfNeeded()

            let imageSize = image.size
            let visibleSize = scrollView.bounds.size

            let hScale = visibleSize.width / imageSize.width
            let vScale = visibleSize.height / imageSize.height
            let minScale = min(hScale, vScale)

            scrollView.minimumZoomScale = minScale
            scrollView.zoomScale = minScale

            let newWidth = imageSize.width * minScale
            let newHeight = imageSize.height * minScale
            imageView.frame.size = CGSize(width: newWidth, height: newHeight)

            scrollView.contentSize = imageView.frame.size

            centerImage()
        }

        private func centerImage() {
            let scrollSize = scrollView.bounds.size
            let contentSize = scrollView.contentSize

            let offsetX = max((scrollSize.width - contentSize.width) / 2, 0)
            let offsetY = max((scrollSize.height - contentSize.height) / 2, 0)

            imageView.frame.origin = CGPoint(x: offsetX, y: offsetY)
        }
    }

    extension SingleImageViewController: UIScrollViewDelegate {
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            imageView
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            centerImage()
        }
    }
