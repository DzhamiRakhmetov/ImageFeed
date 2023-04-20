//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Джами on 23.01.2023.
//

import UIKit

protocol ImageListCellDelegate : AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell  {
    
   // @IBOutlet weak var gradientView : UIImageView!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    weak var delegate: ImageListCellDelegate?
    static let reuseIdentifier = "ImagesListCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    func setIsLiked(isLiked: Bool){
        let liked = UIImage(named: "like_button_on")
        let disLiked = UIImage(named: "like_button_off")
        if isLiked {
            likeButton.setImage(liked, for: .normal)
        } else {
            likeButton.setImage(disLiked, for: .normal)
        }
    }
}



