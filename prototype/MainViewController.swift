//
//  MainViewController.swift
//  prototype
//
//  Created by Jannik Siebert on 07/11/15.
//  Copyright © 2015 halffull. All rights reserved.
//

import UIKit
import CameraManager
import AVFoundation

class MainViewController: UIViewController {

	fileprivate var percentage: Int = -1
	fileprivate let device = UIDevice.current
	fileprivate let screen = UIScreen.main
	fileprivate var isSensorCovered = false
	fileprivate let notificationCenter = NotificationCenter.default
    fileprivate var text: String?
    
    let cameraManager = CameraManager()
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var fillView: UIView!
	@IBOutlet weak var fillHeight: NSLayoutConstraint!
	@IBOutlet weak var labelStatus: UILabel!
	
	func proximityChanged(_ sender: UIDevice) {
		isSensorCovered = device.proximityState
		
		if (isSensorCovered) {
			Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(MainViewController.takeImage), userInfo: nil, repeats: false)
		} else if (percentage != -1) {
			self.fillAnimation(self.percentage)
			self.percentage = -1
		}
	}
	
	func takeImage() {
        cameraManager.capturePictureWithCompletion({ (image:UIImage?, error: NSError?) in
			if image != nil {
				let averageColor = image!.average()
				
				self.percentage = self.getFullness(averageColor) * 25
                let fullness = self.getFullness(averageColor)
				switch fullness {
					case 0:
						self.labelStatus.text = "soo empty"
						self.text = "Your beer is so empty. Get another one already!"
						self.speek(1)
					case 1:
						self.labelStatus.text = "almost empty"
						self.text = "Your beer is almost empty. Get another one!"
						self.speek(1)
					case 2:
						self.labelStatus.text = "looks half full"
						self.text = "Your beer is half full. Looking good!"
						self.speek(1)
					case 3:
						self.labelStatus.text = "looking pretty full"
						self.text = "Your beer is pretty full. Cheers!"
						self.speek(1)
					case 4:
						self.labelStatus.text = "it's soo full"
						self.text = "Your beer is so full. Awesome!"
						self.speek(1)
					default:
						break
				}
			}
		})
	}
	
	func superSecretColorToBeerFunction(_ color: UIColor) -> Int {
		var sat: CGFloat = 0.0
		color.getHue(nil, saturation: &sat, brightness: nil, alpha: nil);
		
		return min(100, (Int) (pow(1.1 * sat, 2.7) * 100))
	}
	
	func fillAnimation(_ percentage: Int) {
		let height = 384.0 - imageView.frame.height * (CGFloat(percentage) / 100)
		
		UIView.animate(withDuration: 1.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
			self.fillHeight.constant = -height
			self.view.layoutIfNeeded()
		}, completion: nil)
	}
    
    func getFullness(_ averageColor: UIColor) -> Int {
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
    
    func speek(_ withDelay: Double) {
        Timer.scheduledTimer(timeInterval: withDelay, target: self, selector: #selector(MainViewController.speek as (MainViewController) -> () -> ()), userInfo: nil, repeats: false)
    }
    
    func speek() {
        let utterance = AVSpeechUtterance(string: text!)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.1
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		screen.wantsSoftwareDimming = false
		device.isProximityMonitoringEnabled = true
		notificationCenter.addObserver(self, selector: #selector(MainViewController.proximityChanged(_:)), name: Notification.Name.UIDeviceProximityStateDidChange, object: device)
        
        cameraManager.writeFilesToPhoneLibrary = false
        cameraManager.cameraDevice = .front
		
		labelStatus.lineBreakMode = .byWordWrapping
		labelStatus.numberOfLines = 0
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
