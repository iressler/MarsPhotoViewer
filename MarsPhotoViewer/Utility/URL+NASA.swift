//
//  URL+NASA.swift
//  MarsPhotoViewer
//
//  Created by Isaac Ressler on 10/18/19.
//  Copyright © 2019 Isaac Ressler. All rights reserved.
//

import Foundation

extension URL {
    private static let defaultComponents: URLComponents = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.nasa.gov"
        components.path = "/mars-photos/api/v1"
        components.queryItems = [URLQueryItem(name: "api_key", value: "7zy0CU6i1nIYHTBQiFyow8KhGFaaLSy5TauxRDrc")]
        return components
    }()
    
    static func manifestURL(for rover: Rover) -> URL {
        var customComponents = defaultComponents
        customComponents.path += "/manifests/\(rover.rawValue)"
        return customComponents.url!
    }
    
    private static func queryItem(for queryDate: QueryDate) -> URLQueryItem {
        switch queryDate {
        case .earth(let date):
            return URLQueryItem(name: "earth_date", value: DateFormatter.NASADateFormatter.string(from: date))
        case .mars(let sol):
            return URLQueryItem(name: "sol", value: "\(sol)")
        }
    }
    
    static func photosURL(for rover: Rover, camera: Camera?, queryDate: QueryDate, page: Int?) -> URL {
        var customComponents = defaultComponents
        customComponents.path += "/rovers/\(rover.rawValue)/photos"
        
        if let camera = camera {
            customComponents.queryItems?.append(URLQueryItem(name: "camera", value: camera.rawValue))
        }
        if let page = page {
            customComponents.queryItems?.append(URLQueryItem(name: "page", value: "\(page)"))            
        }
        customComponents.queryItems?.append(queryItem(for: queryDate))            
        
        return customComponents.url!
    }
}
