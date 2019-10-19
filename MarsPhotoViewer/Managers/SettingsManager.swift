//
//  SettingsManager.swift
//  MarsPhotoViewer
//
//  Created by Isaac Ressler on 10/17/19.
//  Copyright © 2019 Isaac Ressler. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let SettingsChangedNotificationName = Notification.Name("SettingsChanged")
}

private extension String {
    static let RoverDefaultsKey = "RoverName"
    static let QueryDateEarthDefaultsKey = "EarthDateValue"
    static let QueryDateSolDefaultsKey = "SolDateValue"
    static let CameraDefaultsKey = "CameraName"
}

enum QueryDate: Equatable {
    case earth(date: Date)
    case mars(date: Int)
}

struct SettingsError: Error {
    let message: String
}

class SettingsManager {
    static let `default` = SettingsManager()
    
    // This could be done with lazy properties, however that complicates the code and most are needed so close to each other it doesn't matter.
    private init() {
        if let roverName = UserDefaults.standard.string(forKey: .RoverDefaultsKey),
           let rover = Rover(rawValue: roverName) {
            self.currentRover = rover
        }
        
        if let cameraName = UserDefaults.standard.string(forKey: .CameraDefaultsKey),
           let camera = Camera(rawValue: cameraName) {
            self.camera = camera
        }
        
        if let earthDate = UserDefaults.standard.object(forKey: .QueryDateEarthDefaultsKey) as? Date {
            queryDate = .earth(date: earthDate)
        } else if let solDate = UserDefaults.standard.object(forKey: .QueryDateSolDefaultsKey) as? Int {
            queryDate = .mars(date: solDate)
        }
    }
    
    // Make all of these private set with setter functions for consistency since some need to be failable setters.
    private(set) var currentRover: Rover = .Curiosity
    // Minimum is 0, however they don't all have picutres on sol 0, so default to 1.
    private(set) var queryDate: QueryDate = .mars(date: 1)
    private(set) var camera: Camera? = nil
    
    // TODO: Also validate the query date?
    /// This will reset the camera if the selected values are not valid.
    func setCurrentRover(_ newRover: Rover) {
        if newRover == currentRover {
            return
        }
        UserDefaults.standard.set(newRover.rawValue, forKey: .RoverDefaultsKey)
        self.currentRover = newRover
        // Reset camera if it isn't valid.
        if let camera = self.camera, !cameraIsValid(camera) {
            updateCamera(with: nil)
        }
        NotificationCenter.default.post(name: .SettingsChangedNotificationName, object: nil)
    }
    
    func setQueryDate(_ newQueryDate: QueryDate) -> SettingsError? {
        if newQueryDate == queryDate {
            return nil
        }
        // TODO: Validate date against manifest?
        queryDate = newQueryDate
        switch newQueryDate {
        case .earth(let date):
            UserDefaults.standard.removeObject(forKey: .QueryDateSolDefaultsKey)
            UserDefaults.standard.set(date, forKey: .QueryDateEarthDefaultsKey)
        case .mars(let sol):
            UserDefaults.standard.removeObject(forKey: .QueryDateEarthDefaultsKey)
            UserDefaults.standard.set(sol, forKey: .QueryDateSolDefaultsKey)
        }
        NotificationCenter.default.post(name: .SettingsChangedNotificationName, object: nil)
        return nil
    }
    
    private func cameraIsValid(_ camera: Camera) -> Bool {
        return currentRover.cameras().firstIndex(of: camera) != nil
    }
    
    func setCamera(_ newCamera: Camera?) -> SettingsError? {
        if newCamera == camera {
            return nil
        }
        // If a non-nil camera was provided but it's not supported by the rover then don't save it.
        if let newCamera = newCamera, !cameraIsValid(newCamera) { 
            return SettingsError(message: "The currently selected rover (\(currentRover.rawValue)) does not support this camera: \(newCamera.fullName)")
        }
        updateCamera(with: newCamera)
        NotificationCenter.default.post(name: .SettingsChangedNotificationName, object: nil)
        return nil
    }
    
    private func updateCamera(with newCamera: Camera?) {
        camera = newCamera
        UserDefaults.standard.set(newCamera?.rawValue, forKey: .CameraDefaultsKey)
    }
}
