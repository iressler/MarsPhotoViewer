//
//  ServerConnection.swift
//  MarsPhotoViewer
//
//  Created by Isaac Ressler on 10/17/19.
//  Copyright © 2019 Isaac Ressler. All rights reserved.
//

import Foundation
import Alamofire

struct ServerError: Error {
    let message: String
}

// MARK: - Completions
typealias ManifestCompletion = (Swift.Result<Manifest, ServerError>) -> Void
typealias PhotoCompletion = (Swift.Result<[Photo], ServerError>) -> Void

// MARK: - Connection
class ServerConnection {
    // Wrapper around JSONDecodder to move all decoding logic to one place.
    static func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.NASADateFormatter)
        return try decoder.decode(type, from: data)
    }
}

// MARK: - Manifest
extension ServerConnection {
    static func downloadManifests() {
        downloadManifests() { (result: Swift.Result<Manifest, ServerError>) in
            
        }
    }
    
    static func downloadManifests(_ completion: @escaping (Swift.Result<Manifest, ServerError>) -> Void) {
        downloadManifest(for: SettingsManager.default.currentRover, completion: completion)
    }
    
    static func downloadManifest(for rover: Rover, completion: @escaping ManifestCompletion) {
        request(URL.manifestURL(for: rover)).responseJSON { (response: DataResponse<Any>) in
            guard let data = response.data else {
                completion(.failure(ServerError(message: "No data received from server")))
                return
            }
            do {
                // Work around API returning an outer level key to the manifest
                if let manifest = try decode([String: Manifest].self, from: data).values.first {
                    completion(.success(manifest))                    
                } else {
                    completion(.failure(ServerError(message: "Failed to properly decode manifest.")))
                }
            } catch {
                print("Error: \(error)")
                completion(.failure(ServerError(message: String(describing:error))))
            }
        }
    }
}

// MARK: - Photos
extension ServerConnection {
    static func downloadPhotos(page: Int, completion: @escaping PhotoCompletion) {
        let rover = SettingsManager.default.currentRover
        let camera = SettingsManager.default.camera
        let queryDate = SettingsManager.default.queryDate
        request(URL.photosURL(for: rover, camera: camera, queryDate: queryDate, page: page)).responseJSON { (response: DataResponse<Any>) in
            guard let data = response.data else {
                completion(.failure(ServerError(message: "No data received from server")))
                return
            }
            do {
                if let photos = try decode([String: [Photo]].self, from: data).values.first {
                    completion(.success(photos))
                }
            } catch {
                print("Error: \(error)")
                completion(.failure(ServerError(message: String(describing:error))))
            }
        }
    }
}
