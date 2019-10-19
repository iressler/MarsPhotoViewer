//
//  DateFormatter+NASA.swift
//  MarsPhotoViewer
//
//  Created by Isaac Ressler on 10/18/19.
//  Copyright © 2019 Isaac Ressler. All rights reserved.
//

import Foundation

extension DateFormatter {
  static let NASADateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyy-MM-dd"
    return df
  }()
}

