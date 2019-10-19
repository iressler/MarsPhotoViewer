//
//  ImageViewController.swift
//  MarsPhotoViewer
//
//  Created by Isaac Ressler on 10/17/19.
//  Copyright © 2019 Isaac Ressler. All rights reserved.
//

import UIKit
import AlamofireImage

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var imageView: UIImageView!
    
    var imageURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.af_setImage(withURL: imageURL)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
