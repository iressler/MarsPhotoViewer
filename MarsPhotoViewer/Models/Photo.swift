//
//  Photo.swift
//  MarsPhotoViewer
//
//  Created by Isaac Ressler on 10/17/19.
//  Copyright © 2019 Isaac Ressler. All rights reserved.
//

import Foundation

struct Photo: Decodable {
    let id: Int
    let sol: Int
    let date: Date
    let camera: PhotoCamera
    private let imageURLString: String
    let rover: PhotoRover
    
    var imageURL: URL {
        var components = URLComponents(string: imageURLString)!
        components.scheme = "https"
        return components.url!
    }
    
    var dateString: String {
        return DateFormatter.NASADateFormatter.string(from: date)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case sol
        case date = "earth_date"
        case camera
        case imageURLString = "img_src"
        case rover
    }
}

// Photo has a different set of data for the camera than the other APIs.
struct PhotoCamera: Decodable {
    let id: Int
    let name: String
    let roverID: Int
    let fullName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case roverID = "rover_id"
        case fullName = "full_name"
    }
}

// Photo has a different set of data for the rover than the other APIs.
struct PhotoRover: Decodable {
    let id: Int
    let roverName: String
    let launchDate: Date
    let landingDate: Date
    let status: String
    let maxSol: Int
    let maxDate: Date
    let totalPhotos: Int
    let cameras: [PhotoRoverCamera]
    
    enum CodingKeys: String, CodingKey {
        case id
        case roverName = "name"
        case launchDate = "launch_date"
        case landingDate = "landing_date"
        case status
        case maxSol = "max_sol"
        case maxDate = "max_date"
        case totalPhotos = "total_photos"
        case cameras = "cameras"
    }
}

struct PhotoRoverCamera: Decodable {
    let name: String
    let fullName: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case fullName = "full_name"
    }
}
