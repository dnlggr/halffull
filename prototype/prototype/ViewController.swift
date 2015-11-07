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
    @IBOutlet weak var averageColorView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelHsv: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    
	
	@IBAction func tapButton(sender: UIButton) {
		CameraManager.sharedInstance.addPreviewLayerToView(self.preview)
		CameraManager.sharedInstance.cameraDevice = .Front
        CameraManager.sharedInstance.writeFilesToPhoneLibrary = false
        
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "takeImage", userInfo: nil, repeats: true)
	}
    
    func takeImage() {
        CameraManager.sharedInstance.capturePictureWithCompletition({ (image, error) in
            if image != nil {
                self.pictureView.image = image!
                let averageColor = image!.average()
                self.averageColorView.backgroundColor =  averageColor
                self.label.text = "R: \(CIColor(color: averageColor).red) G: \(CIColor(color: averageColor).green) B: \(CIColor(color: averageColor).blue)"
                
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
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

