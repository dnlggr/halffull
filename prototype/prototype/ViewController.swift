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
	
	private let device = UIDevice.currentDevice()
	private let screen = UIScreen.mainScreen()
	private var isSensorCovered = false
	private let notificationCenter = NSNotificationCenter.defaultCenter()
	
	@IBOutlet weak var preview: UIView!
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var averageColorView: UIView!
	@IBOutlet weak var proximityLabel: UILabel!
	@IBOutlet weak var labelHsv: UILabel!
	@IBOutlet weak var labelStatus: UILabel!
	
	@IBAction func tapButton(sender: AnyObject) {
		takeImage()
	}
	
	func proximityChanged(sender: UIDevice) {
		isSensorCovered = device.proximityState
		proximityLabel.text = "Proximity: \(isSensorCovered)"
		
		if (isSensorCovered) {
			NSTimer.scheduledTimerWithTimeInterval(0.75, target: self, selector: "takeImage", userInfo: nil, repeats: false)
			device.proximityMonitoringEnabled = false
		}
	}
	
    func takeImage() {
        CameraManager.sharedInstance.capturePictureWithCompletition({ (image, error) in
            if image != nil {
                self.pictureView.image = image!
                let averageColor = image!.average()
                self.averageColorView.backgroundColor = averageColor
                
                var hue: CGFloat = 0.0
                var sat: CGFloat = 0.0
                var val: CGFloat = 0.0
                var alp: CGFloat = 0.0
                averageColor.getHue(&hue, saturation: &sat, brightness: &val, alpha: &alp);
                
                self.labelHsv.text = "H: \(hue) S: \(sat) V: \(val)"
                
                if sat > 0.9 {
                    self.labelStatus.text = "fully saturated"
                } else {
                    self.labelStatus.text = nil
                }
            }
        })
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		screen.wantsSoftwareDimming = false
		
		device.proximityMonitoringEnabled = true
		notificationCenter.addObserver(self, selector: "proximityChanged:", name: UIDeviceProximityStateDidChangeNotification, object: device)
		
		CameraManager.sharedInstance.writeFilesToPhoneLibrary = false
		
		CameraManager.sharedInstance.addPreviewLayerToView(self.preview)
		CameraManager.sharedInstance.cameraDevice = .Front
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
