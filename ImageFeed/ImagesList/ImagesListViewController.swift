//
//  ViewController.swift
//  ImageFeed
//
//  Created by Джами on 23.01.2023.
//

import UIKit
import Kingfisher
import ProgressHUD

final class ImagesListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    
    // private let photosName: [String] = Array(0..<20).map{"\($0)"}
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos : [Photo] = []
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        UIBlockingProgressHUD.show()
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main) {[weak self] _ in
                guard let self = self else {return}
                self.updateTableViewAnimated()
                UIBlockingProgressHUD.dismiss()
            }
        imagesListService.fetchPhotosNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            let fullImageURL = URL(string: photos[indexPath.row].fullImageURL)
            viewController.fullImageURL = fullImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount{
            tableView.performBatchUpdates {
                let indexPath = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPath, with: .automatic)
            } completion: { _ in }
        }
    }
    
    // MARK: - Alert
    
    private func showLikeAlert(with error: Error) {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Действие временно недоступно, попробуйте позднее",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: - Extensions TableViewDelegate & DataSource

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == imagesListService.photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController : UITableViewDataSource {
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath ) {
        guard let thumbURL = URL(string: photos[indexPath.row].thumbImageURL),
              let placeholder = UIImage(named: "Stub") else {return}
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: thumbURL, placeholder: placeholder) { _ in
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        cell.setIsLiked(isLiked: photos[indexPath.row].isLiked)
        guard let date = photos[indexPath.row].createdAt else {
            cell.dateLabel.text = nil
            return
        }
        cell.dateLabel.text = dateFormatter.string(from: date)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}


// MARK: - Extension ImageListCellDelegate

extension ImagesListViewController: ImageListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLikes(photoID: photo.id, isLike: !photo.isLiked) { [weak self]  result in
            guard let self = self else {return}
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                self.showLikeAlert(with: error)
            }
        }
    }
}
