//
//  PhotoListCollectionViewController.swift
//  MarsPhotoViewer
//
//  Created by Isaac Ressler on 10/17/19.
//  Copyright © 2019 Isaac Ressler. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

private let reuseIdentifier = "PhotoCell"

class PhotoListCollectionViewController: UICollectionViewController {
    private var downloader: PhotoDownloader?
    private var notifRegisterToken: NSObjectProtocol?
    
    // Placeholder image scaled to the correct size.
    private lazy var downloadPlaceholder: UIImage = {
        let image = UIImage(systemName: "icloud.and.arrow.down")!.withTintColor(.red)
        return ScaledToSizeFilter(size: self.itemSize).filter(image)
    }()
    
    // Size of the cells
    private lazy var itemSize: CGSize = {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        let insets = flowLayout.sectionInset
        let spacing = insets.right + insets.left + flowLayout.minimumInteritemSpacing
        // - 2.0 because the cell has it's size slightly increased on some devices pushing it to one cell per row.
        let size = ((collectionView.bounds.size.width - spacing) / 2.0) - 2.0
        return CGSize(width: size, height: size)
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // layout should always be flowLayout, but avoid crashing if it changes.
        (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = itemSize
        notifRegisterToken = NotificationCenter.default.addObserver(forName: .SettingsChangedNotificationName, object: nil, queue: .main) {[weak self] (notif: Notification) in
            self?.updateDownloader()
            self?.collectionView.reloadData()
        }
        self.updateDownloader()
    }
    
    // Should never be called, but better safe.
    deinit {
        // Should always be set, but doesn't hurt.
        if let token = notifRegisterToken {
            NotificationCenter.default.removeObserver(token)            
        }
    }
    
    private func updateDownloader() {
        // If there was already a downloader unset the delegate so there can't be two calling into this class with downloads.
        downloader?.delegate = nil
        downloader = PhotoDownloader(delegate: self)
        downloader?.loadMorePhotos()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "ImageSegue", let destination = segue.destination as? ImageViewController {
            let indexPath = collectionView.indexPathsForSelectedItems!.first!
            let photo = downloader!.photo(at: indexPath)!
            destination.imageURL = photo.imageURL
            destination.title = photo.camera.name + " on " + photo.rover.roverName + " taken " + photo.dateString
        }
    }
    
    // MARK: - UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return downloader?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // If near the end of the list load the next page of results.
        if let downloader = self.downloader, indexPath.row > downloader.count - 10 {
            // Can call extra times because it ignores them if it is already loading.
            downloader.loadMorePhotos()
        }
        
        // TODO: add a loading cell at the end if there are more results to load.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let photoCell = cell as? PhotoCollectionViewCell {
            if let photo = downloader!.photo(at: indexPath) {
                photoCell.imageView.af_setImage(withURL: photo.imageURL, placeholderImage: downloadPlaceholder, filter: ScaledToSizeFilter(size: itemSize))
                photoCell.title.text = photo.camera.name + " on " + photo.rover.roverName
            // This should never happen, but fail gracefully.
            } else {
                photoCell.imageView.image = downloadPlaceholder
                photoCell.title.text = "Loading..."
            }
        } else {
            print("Failed to get a cell and photo data!")
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension PhotoListCollectionViewController: UICollectionViewDataSourcePrefetching {
    // Not working?
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        downloader?.loadMorePhotos()
    }
    
    // TODO
//    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
//    }
}

// MARK: - PhotoDownloaderDelegate
extension PhotoListCollectionViewController: PhotoDownloaderDelegate {
    func loadCompleted(with newIndexes: [IndexPath]) {
        collectionView.reloadData()
        // TODO: This should be used, however there are some cases (when settings change?) where it's causing a crash
//        collectionView.insertItems(at: newIndexes)
    }
    
    func loadFailed(with error: ServerError) {
        let alert = UIAlertController(title: "Error", message: "There was an error loading the photo information: \(error.message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
