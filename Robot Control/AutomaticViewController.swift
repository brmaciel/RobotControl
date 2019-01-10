//
//  AutomaticViewController.swift
//  My Robot
//
//  Created by Bruno Maciel on 11/23/16.
//  Copyright © 2016 Bruno Maciel. All rights reserved.
//

import UIKit
import CoreBluetooth

class AutomaticViewController: UIViewController {

    @IBOutlet weak var switchAutoPilot: UISwitch!
    
    @IBOutlet weak var imgSensorF: UIImageView!
    @IBOutlet weak var imgSensorB: UIImageView!
    @IBOutlet weak var imgSensorL: UIImageView!
    @IBOutlet weak var imgSensorR: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func turnAutoPilotOnOff(_ sender: AnyObject) {
        if switchAutoPilot.isOn {
            print("Auto Pilot ON")
            imgSensorF.isHighlighted = true
            imgSensorB.isHighlighted = true
            imgSensorL.isHighlighted = true
            imgSensorR.isHighlighted = true
        } else {
            print("Auto Pilot OFF")
            imgSensorF.isHighlighted = false
            imgSensorB.isHighlighted = false
            imgSensorL.isHighlighted = false
            imgSensorR.isHighlighted = false
        }
    }
    
}
