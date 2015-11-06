//
//  ViewController.swift
//  prototype
//
//  Created by Jannik Siebert on 06/11/15.
//  Copyright © 2015 halffull. All rights reserved.
//

import UIKit
import CameraManager

class ViewController: UIViewController {
	
	@IBOutlet weak var preview: UIView!
    @IBOutlet weak var pictureView: UIImageView!
    
	
	@IBAction func tapButton(sender: UIButton) {
		CameraManager.sharedInstance.addPreviewLayerToView(self.preview)
		CameraManager.sharedInstance.cameraDevice = .Front
        
        _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "takeImage", userInfo: nil, repeats: true)
	}
    
    func takeImage() {
        CameraManager.sharedInstance.capturePictureWithCompletition({ (image, error) in
            if image != nil {
                self.pictureView.image = image!
            }
        })
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

