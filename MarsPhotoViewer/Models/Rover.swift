//
//  Rover.swift
//  MarsPhotoViewer
//
//  Created by Isaac Ressler on 10/17/19.
//  Copyright © 2019 Isaac Ressler. All rights reserved.
//

import Foundation

enum Rover: String, CaseIterable, Decodable {
    case Curiosity
    case Opportunity
//    case Spirit // TODO: There is a coding error with the Spirit Manifest, figure out what is wrong.
    
    func cameras() -> [Camera] {
        switch self {
        case .Curiosity:
            return [.FHAZ, .RHAZ, .MAST, .CHEMCAM, .MAHLI, .MARDI, .NAVCAM]
        case .Opportunity: //, .Spirit:
            return [.ENTRY, .FHAZ, .RHAZ, .NAVCAM, .PANCAM, .MINITES]
        }
    }
}

enum Camera: String, Decodable {
    case ENTRY // Not documented?
    case FHAZ
    case RHAZ
    case MAST
    case CHEMCAM
    case MAHLI
    case MARDI
    case NAVCAM
    case PANCAM
    case MINITES
    
    var fullName: String {
        switch self {
        case .ENTRY:
            return "Entry"
        case .FHAZ:
            return "Front Hazard Avoidance Camera"
        case .RHAZ:
            return "Rear Hazard Avoidance Camera"
        case .MAST:
            return "Mast Camera"
        case .CHEMCAM:
            return "Chemistry and Camera Complex"
        case .MAHLI:
            return "Mars Hand Lens Imager"
        case .MARDI:
            return "Mars Descent Imager"
        case .NAVCAM:
            return "Navigation Camera"
        case .PANCAM:
            return "Panoramic Camera"
        case .MINITES:
            return "Miniature Thermal Emission Spectrometer"
        }
    }
}
