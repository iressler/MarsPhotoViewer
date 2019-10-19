//
//  PhotoDownloader.swift
//  MarsPhotoViewer
//
//  Created by Isaac Ressler on 10/17/19.
//  Copyright © 2019 Isaac Ressler. All rights reserved.
//

import Foundation

protocol PhotoDownloaderDelegate: class {
    func loadCompleted(with newIndexes: [IndexPath])
    func loadFailed(with error: ServerError)
}

class PhotoDownloader {
    weak var delegate: PhotoDownloaderDelegate?
    private(set) var isLoading = false
    // Private to prevent modification of photos since other logic relies on the array not being modified.
    private var photos = [Photo]()
    private var page = 1
    
    var count: Int {
        return photos.count
    }
    
    init(delegate: PhotoDownloaderDelegate) {
        self.delegate = delegate
    }
    
    func photo(at indexPath: IndexPath) -> Photo? {
        guard indexPath.row < photos.count else {
            return nil
        }
        return photos[indexPath.row]
    }
    
    func loadMorePhotos() {
        guard !isLoading else {
            print("Load called while already loading")
            return
        } // TODO: Add logic to detect when the end of the photos has been reached.
        
        isLoading = true
        
        ServerConnection.downloadPhotos(page: page) { [weak self] (result: Result<[Photo], ServerError>) in
            guard let self = self else {
                return
            }
            self.isLoading = false
            switch result {
            case .success(let photos):
                self.photos.append(contentsOf: photos)
                self.delegate?.loadCompleted(with: self.lastIndexPaths(photos.count))
            case .failure(let error):
                self.delegate?.loadFailed(with: error)
            }
        }
    }
    
    private func lastIndexPaths(_ count: Int) -> [IndexPath] {
        return (photos.count - count..<photos.count).map {IndexPath(row: $0, section: 0) }
    }
}
