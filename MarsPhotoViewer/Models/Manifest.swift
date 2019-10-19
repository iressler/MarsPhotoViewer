//
//  Manifest.swift
//  MarsPhotoViewer
//
//  Created by Isaac Ressler on 10/17/19.
//  Copyright © 2019 Isaac Ressler. All rights reserved.
//

import Foundation

struct Manifest: Decodable {
    let roverName: String
    let launchDate: Date
    let landingDate: Date
    let status: String
    let maxSol: Int
    let maxDate: Date
    let totalPhotos: Int
    let photoMetadata: [ManifestPhotoMetadata]
    
    enum CodingKeys: String, CodingKey {
        case roverName = "name"
        case launchDate = "launch_date"
        case landingDate = "landing_date"
        case status
        case maxSol = "max_sol"
        case maxDate = "max_date"
        case totalPhotos = "total_photos"
        case photoMetadata = "photos"
    }
}

struct ManifestPhotoMetadata: Decodable {
    let sol: Int
    let date: Date
    let count: Int
    let cameras: [Camera]
    
    enum CodingKeys: String, CodingKey {
        case sol
        case date = "earth_date"
        case count = "total_photos"
        case cameras
    }
}
