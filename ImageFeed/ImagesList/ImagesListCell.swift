//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Алена Апарина on 10.10.2025.
//
import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"

    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBAction func didTapLike(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }

    func setIsLiked(_ isLiked: Bool) {
        let image = isLiked ? UIImage(resource: .active) : UIImage(resource: .noActive)
        likeButton.setImage(image, for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        dateLabel.text = nil
        likeButton.setImage(nil, for: .normal)
    }
}
