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
	
	fileprivate let device = UIDevice.current
	fileprivate let screen = UIScreen.main
	fileprivate var isSensorCovered = false
	fileprivate let notificationCenter = NotificationCenter.default
    
    let cameraManager = CameraManager()
	
	@IBOutlet weak var preview: UIView!
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var averageColorView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelHsv: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
	
	@IBAction func tapButton(_ sender: UIButton) {
        takeImage()
	}
	
	func proximityChanged(_ sender: UIDevice) {
		isSensorCovered = device.proximityState
		
		if (isSensorCovered) {
			Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(ViewController.takeImage), userInfo: nil, repeats: false)
//			device.proximityMonitoringEnabled = false
		}
	}
    
    func takeImage() {
        cameraManager.capturePictureWithCompletion({ (image: UIImage?, error: NSError?) in
            if image != nil {
                self.pictureView.image = image!
                let averageColor = image!.average()
                self.averageColorView.backgroundColor =  averageColor
                self.label.text = "R: \(CIColor(color: averageColor).red) G: \(CIColor(color: averageColor).green) B: \(CIColor(color: averageColor).blue)"
                
                var hue: CGFloat = 0.0
                var sat: CGFloat = 0.0
                var val: CGFloat = 0.0
                averageColor.getHue(&hue, saturation: &sat, brightness: &val, alpha: nil);
                
                self.labelHsv.text = "H: \(String(format: "%.4f", Float(hue))) S: \(String(format: "%.4f", Float(sat))) V: \(String(format: "%.4f", Float(val)))"
				
//				self.labelStatus.text = String(format: "%d Percent full", self.superSecretColorToBeerFunction(averageColor))
				switch self.superSecretColorToBeerFunction(averageColor) {
					case let percent where percent <= 1:
						self.labelStatus.text = "soo empty"
					case let percent where percent > 1 && percent <= 25:
						self.labelStatus.text = "almost empty"
					case let percent where percent > 25 && percent <= 60:
						self.labelStatus.text = "looks half full"
					case let percent where percent > 60 && percent <= 90:
						self.labelStatus.text = "looking pretty full"
					case let percent where percent > 90:
						self.labelStatus.text = "it's soo full"
					default: break
				}
            }
        })
    }
	
	func superSecretColorToBeerFunction(_ color: UIColor) -> Int {
		var sat: CGFloat = 0.0
		color.getHue(nil, saturation: &sat, brightness: nil, alpha: nil);
		
		return min(100, (Int) (pow(1.1 * sat, 2.7) * 100))
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		screen.wantsSoftwareDimming = false
		device.isProximityMonitoringEnabled = true
		notificationCenter.addObserver(self, selector: #selector(ViewController.proximityChanged(_:)), name: Notification.Name.UIDeviceProximityStateDidChange, object: device)
		
		cameraManager.writeFilesToPhoneLibrary = false
		cameraManager.addPreviewLayerToView(self.preview)
		cameraManager.cameraDevice = .front
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
    
    // MARK: Navigation

    @IBAction func buttonStartPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToBeerScreen", sender: self)
    }
}
