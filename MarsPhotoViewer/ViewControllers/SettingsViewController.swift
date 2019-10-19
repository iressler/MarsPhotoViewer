//
//  SettingsViewController.swift
//  MarsPhotoViewer
//
//  Created by Isaac Ressler on 10/18/19.
//  Copyright © 2019 Isaac Ressler. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    // Rover
    @IBOutlet var roverPicker: UIPickerView!
    // Date
    @IBOutlet var dateTypeControl: UISegmentedControl!
    @IBOutlet var solDatePicker: UIPickerView!
    @IBOutlet var earthDatePicker: UIDatePicker!
    // Camera
    @IBOutlet var cameraPicker: UIPickerView!
    
    var currentManifest: Manifest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSettingsViews()
    }
    
    func loadManifest(for rover: Rover) {
        ServerConnection.downloadManifest(for: rover) { (result: Swift.Result<Manifest, ServerError>) in
            switch result {
            case .success(let manifest):
                self.currentManifest = manifest
                DispatchQueue.main.async {
                    self.updateSettingsViews()
                }
            case .failure(let error):
                self.showError(message: "Error loading manifest from server: \(error)")
            }
        }
    }
    
    func updateSettingsViews() {
        let sm = SettingsManager.default
        let currentRover = sm.currentRover
        guard let manifest = self.currentManifest, currentRover.rawValue == manifest.roverName else {
            // TODO: Add some loading view here?
            loadManifest(for: currentRover)
            return
        }
        roverPicker.selectRow(Rover.allCases.firstIndex(of: currentRover)!, inComponent: 0, animated: true)
        // Do not need to reload Rover because that controls everything else.
        self.solDatePicker.reloadAllComponents()
        self.cameraPicker.reloadAllComponents()
        
        // Effectively reloads date picker.
        earthDatePicker.minimumDate = manifest.launchDate
        earthDatePicker.maximumDate = manifest.maxDate
        
        switch sm.queryDate {
        case .earth(let date):
            dateTypeControl.selectedSegmentIndex = 0
            solDatePicker.isHidden = true
            earthDatePicker.isHidden = false
            earthDatePicker.date = date
        case .mars(let sol):
            dateTypeControl.selectedSegmentIndex = 1
            solDatePicker.isHidden = false
            earthDatePicker.isHidden = true
            solDatePicker.selectRow(sol, inComponent: 0, animated: true)
        }
        
        let cameraIndex: Int
        if let camera = sm.camera, let index = currentRover.cameras().firstIndex(of: camera) {
            cameraIndex = index + 1
        } else {
            cameraIndex = 0
        }
        
        cameraPicker.selectRow(cameraIndex, inComponent: 0, animated: true)
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Values changed
    @IBAction func segmentedControlIndexChanged(_ sender: UISegmentedControl) {
        let newQueryDate: QueryDate
        if sender.selectedSegmentIndex == 0 {
            newQueryDate = .earth(date: earthDatePicker.minimumDate!)
        } else {
            newQueryDate = .mars(date: 1)
        }
        print("Index changed to: \(sender.selectedSegmentIndex)")
        if let error = SettingsManager.default.setQueryDate(newQueryDate) {
            showError(message: String(describing: error))
        }
        updateSettingsViews()
    }
    
    @IBAction func earthDatePickerDateChanged(_ sender: UIDatePicker) {
        if let error = SettingsManager.default.setQueryDate(.earth(date: sender.date)) {
            showError(message: String(describing: error))            
        }
        updateSettingsViews()
    }
}

// MARK: - UIPickerViewDataSource
extension SettingsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // ALl of the (non-date) pickers have 1 component
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == roverPicker {
            return Rover.allCases.count
        } else if pickerView == solDatePicker {
            if let manifest = currentManifest {
                return manifest.maxSol
            } else {
                return 1
            }
        } else if pickerView == cameraPicker {
            return SettingsManager.default.currentRover.cameras().count + 1
        } else {
            fatalError("Unrecoginzed picker: \(pickerView)")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == roverPicker {
            return Rover.allCases[row].rawValue
        } else if pickerView == solDatePicker {
            return "\(row)"
        } else if pickerView == cameraPicker {
            if row == 0 {
                return "All"
            } else {
                return SettingsManager.default.currentRover.cameras()[row - 1].rawValue
            }
        } else {
            fatalError("Unrecognized picker: \(pickerView)")
        }
    }
}

// MARK: - UIPickerViewDelegate
extension SettingsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let sm = SettingsManager.default
        if pickerView == roverPicker {
            sm.setCurrentRover(Rover.allCases[row])
        } else if pickerView == solDatePicker {
            // Shouldn't error, but better safe.
            if let error = sm.setQueryDate(.mars(date: row)) {
                self.showError(message: String(describing: error))
            }
        } else if pickerView == cameraPicker {
            var newCamera: Camera? = nil
            if row > 0 {
                newCamera = sm.currentRover.cameras()[row - 1]
            }
            // Shouldn't error, but better safe.
            if let error = sm.setCamera(newCamera) {
                self.showError(message: String(describing: error))
            }
        } else {
            fatalError("Unrecognized picker: \(pickerView)")
        }
        updateSettingsViews()
    }
    
    func showError(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
