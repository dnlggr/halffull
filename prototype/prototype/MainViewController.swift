//
//  MainViewController.swift
//  prototype
//
//  Created by Jannik Siebert on 07/11/15.
//  Copyright © 2015 halffull. All rights reserved.
//

import UIKit
import CameraManager

class MainViewController: UIViewController {

	private var percentage: Int = -1
	private let device = UIDevice.currentDevice()
	private let screen = UIScreen.mainScreen()
	private var isSensorCovered = false
	private let notificationCenter = NSNotificationCenter.defaultCenter()
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var fillView: UIView!
	@IBOutlet weak var fillHeight: NSLayoutConstraint!
	@IBOutlet weak var labelStatus: UILabel!
	
	func proximityChanged(sender: UIDevice) {
		isSensorCovered = device.proximityState
		
		if (isSensorCovered) {
			NSTimer.scheduledTimerWithTimeInterval(0.75, target: self, selector: "takeImage", userInfo: nil, repeats: false)
		} else if (percentage != -1) {
			self.fillAnimation(self.percentage)
			self.percentage = -1
		}
	}
	
	func takeImage() {
		CameraManager.sharedInstance.capturePictureWithCompletition({ (image, error) in
			if image != nil {
				let averageColor = image!.average()
				
				self.percentage = self.superSecretColorToBeerFunction(averageColor)
                let fullness = self.getFullness(averageColor)
				switch fullness {
                case 0:
                    self.labelStatus.text = "soo empty"
                case 1:
                    self.labelStatus.text = "almost empty"
                case 2:
                    self.labelStatus.text = "looks half full"
                case 3:
                    self.labelStatus.text = "looking pretty full"
                case 4:
                    self.labelStatus.text = "it's soo full"
                default:
                    break
				}
			}
		})
	}
	
	func superSecretColorToBeerFunction(color: UIColor) -> Int {
		var sat: CGFloat = 0.0
		color.getHue(nil, saturation: &sat, brightness: nil, alpha: nil);
		
		return min(100, (Int) (pow(1.1 * sat, 2.7) * 100))
	}
	
	func fillAnimation(percentage: Int) {
		let height = 200.0 - imageView.frame.height * (CGFloat(percentage) / 100)
		
		UIView.animateWithDuration(1.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
			self.fillHeight.constant = -height
			self.view.layoutIfNeeded()
		}, completion: nil)
	}
    
    func getFullness(averageColor: UIColor) -> Int {
        switch self.superSecretColorToBeerFunction(averageColor) {
        case let percent where percent <= 1:
            return 0
        case let percent where percent > 1 && percent <= 25:
            return 1
        case let percent where percent > 25 && percent <= 60:
            return 2
        case let percent where percent > 60 && percent <= 90:
            return 3
        case let percent where percent > 90:
            return 4
        default: return -1
        }
    }

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		screen.wantsSoftwareDimming = false
		device.proximityMonitoringEnabled = true
		notificationCenter.addObserver(self, selector: "proximityChanged:", name: UIDeviceProximityStateDidChangeNotification, object: device)
		
		CameraManager.sharedInstance.writeFilesToPhoneLibrary = false
		CameraManager.sharedInstance.cameraDevice = .Front
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	////		if (segue.identifier == "startMainViewController") {
	////			let dest = segue.destinationViewController as! MainViewController
	////			dest.percentage =
	////		}
	//		// Get the new view controller using segue.destinationViewController.
	//		// Pass the selected object to the new view controller.
	//	}
}
