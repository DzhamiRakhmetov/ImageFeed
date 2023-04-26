//
//  ViewController.swift
//  ImageFeed
//
//  Created by Джами on 23.01.2023.
//

import UIKit
import Kingfisher
import ProgressHUD

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? {get set}
    func didReceivePhotosForTableViewAnimatedUpdate(at indexPath: [IndexPath], new array: [Photo])
    func isLike(indexPath: IndexPath, isOn: Bool)
    func showLikeAlert(with: Error)
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    
    @IBOutlet private weak var tableView: UITableView!
    var presenter: ImagesListPresenterProtocol?
    private var imagesListServiceObserver: NSObjectProtocol?
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter?.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            guard let string  = presenter?.photos[indexPath.row].fullImageURL else {return}
            let fullImageURL = URL(string: string)
            viewController.fullImageURL = fullImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Alert
    
    internal func showLikeAlert(with error: Error) {
        UIBlockingProgressHUD.dismiss()
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Действие временно недоступно, попробуйте позднее",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    func isLike(indexPath: IndexPath, isOn: Bool) {
        UIBlockingProgressHUD.dismiss()
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else {return}
        cell.setIsLiked(isLiked: isOn)
    }
    
    // MARK: - Protocol Methods
    func didReceivePhotosForTableViewAnimatedUpdate(at indexPath: [IndexPath], new array: [Photo]) {
//        presenter?.photos = array
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPath, with: .automatic)
        }
    }
}

//MARK: - Extensions TableViewDelegate & DataSource

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.photos[indexPath.row] else {return .zero}
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
        presenter?.updateNextPageIfNeeded(forRowAt: indexPath)
    }
}

extension ImagesListViewController : UITableViewDataSource {
    
   private func configCell(for cell: ImagesListCell, with indexPath: IndexPath ) {
       guard let photos = presenter?.photos, let thumbURL = URL(string: photos[indexPath.row].thumbImageURL),
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
        return presenter?.photos.count ?? 0
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
        UIBlockingProgressHUD.show()
        presenter?.selectLike(indexPath: indexPath)
    }
}
