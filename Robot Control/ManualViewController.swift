//
//  ManualViewController.swift
//  My Robot
//
//  Created by Bruno Maciel on 11/22/16.
//  Copyright © 2016 Bruno Maciel. All rights reserved.
//

import UIKit
import CoreBluetooth

class ManualViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var viewFB: UIView!
    @IBOutlet weak var viewLR: UIView!
    @IBOutlet weak var imgFB: UIImageView!
    @IBOutlet weak var imgLR: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var switchAntiCollision: UISwitch!
    
    var direction = CGPoint()
    var dataX = 0
    var dataY = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UITabBar.appearance().tintColor = UIColor(red: 40/255, green: 120/255, blue: 200/255, alpha: 1.0)  //color of selected Tab Icon and Text
        self.tabBarController!.tabBar.barTintColor = UIColor(red: 12/255, green: 10/255, blue: 9/255, alpha: 1.0)  //color of Tab Bar
        
        initializePanGesture()
        direction.x = 0.0; direction.y = 0.0
        label.text = "( \(direction.y) , \(direction.x) )"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func turnAntiCollisionOnOff(_ sender: AnyObject) {
        if switchAntiCollision.isOn {
            print("Anti-Collision ON")
        } else {
            print("Anti-Collision OFF")
        }
    }
    
    func initializePanGesture() {
        let FB = UIPanGestureRecognizer(target: self, action: #selector(ManualViewController.handlePanFB(_:)))
        viewFB.addGestureRecognizer(FB)
        
        let LR = UIPanGestureRecognizer(target: self, action: #selector(ManualViewController.handlePanLR(_:)))
        viewLR.addGestureRecognizer(LR)
    }
    
    // Pan é o gesto de clicar e arrastar em uma mesma view
    func handlePanFB(_ sender: UIPanGestureRecognizer) {
        let imgW : CGFloat = 50
        let halfW = imgW/2
        
        // Antes de mover, verificamos que já terminou de arrastar, soltando o dedo da tela
        if sender.state == UIGestureRecognizerState.changed || sender.state == UIGestureRecognizerState.began {
            let p = sender.location(in: self.viewFB)
            //print(p)
            //label.text = "( \(p.y) , \(imgFB.center.x) )"
            
            if p.y > 200 {
                UIView.animate(withDuration: 0.0, animations: {self.imgFB.frame = CGRect(x: self.imgFB.frame.origin.x, y: 200-halfW, width: imgW, height: imgW)} )
            } else if p.y < 0 {
                UIView.animate(withDuration: 0.0, animations: {self.imgFB.frame = CGRect(x: self.imgFB.frame.origin.x, y: 0-halfW, width: imgW, height: imgW)} )
            } else {
                UIView.animate(withDuration: 0.0, animations: {self.imgFB.frame = CGRect(x: self.imgFB.frame.origin.x, y: p.y-halfW, width: imgW, height: imgW)} )
            }
            
            if imgFB.center.y < 100 {
                direction.y = 100 - imgFB.center.y
                label.text = "( \(direction.y) , \(direction.x) )"
            } else {
                direction.y = 100 - imgFB.center.y
                label.text = "( \(direction.y) , \(direction.x) )"
            }
            
            dataY = Int(direction.y)
            writeValue(convertStr(dataY, numX: dataX))
            
        } else if sender.state == UIGestureRecognizerState.ended {
            //let p = sender.locationInView(self.imgFB)
            //print(p)
            UIView.animate(withDuration: 0.5, animations: {self.imgFB.frame = CGRect(x: self.imgFB.frame.origin.x, y: 100-halfW, width: imgW, height: imgW)} )
            direction.y = 0.0
            label.text = "( \(direction.y), \(direction.x) )"
            
            dataY = Int(direction.y)
            writeValue(convertStr(dataY, numX: dataX))
        }
    }
    func handlePanLR(_ sender: UIPanGestureRecognizer) {
        let imgW : CGFloat = 50
        let halfW = imgW/2
        
        // Antes de mover, verificamos que já terminou de arrastar, soltando o dedo da tela
        if sender.state == UIGestureRecognizerState.changed || sender.state == UIGestureRecognizerState.began {
            let p = sender.location(in: self.viewLR)
            print(p)
            
            if p.x > 200 {
                UIView.animate(withDuration: 0.0, animations: {self.imgLR.frame = CGRect(x: 200-halfW, y: self.imgLR.frame.origin.y, width: imgW, height: imgW)} )
            } else if p.x < 0 {
                UIView.animate(withDuration: 0.0, animations: {self.imgLR.frame = CGRect(x: 0-halfW, y: self.imgLR.frame.origin.y, width: imgW, height: imgW)} )
            } else {
                UIView.animate(withDuration: 0.0, animations: {self.imgLR.frame = CGRect(x: p.x-halfW, y: self.imgLR.frame.origin.y, width: imgW, height: imgW)} )
            }
            
            if imgLR.center.x < 100 {
                direction.x = imgLR.center.x - 100
                label.text = "( \(direction.y) , \(direction.x) )"
            } else {
                direction.x = imgLR.center.x - 100
                label.text = "( \(direction.y) , \(direction.x) )"
            }
            
            dataX = Int(direction.x)
            writeValue(convertStr(dataY, numX: dataX))
            
        } else if sender.state == UIGestureRecognizerState.ended {
            //let p = sender.locationInView(self.viewLR)
            //print(p)
            UIView.animate(withDuration: 0.5, animations: {self.imgLR.frame = CGRect(x: 100-halfW, y: self.imgLR.frame.origin.y, width: imgW, height: imgW)} )
            direction.x = 0.0
            label.text = "( \(direction.y), \(direction.x) )"
            
            dataX = Int(direction.x)
            writeValue(convertStr(dataY, numX: dataX))
        }
    }
    
    
    func convertStr(_ numY : Int, numX : Int) -> String {
        var str = String();
        if abs(numY) == 100 {
            str = String(numY)
        } else if numY < -9 {
            str = "-0" + String(abs(numY))
        } else if numY < 0 {
            str = "-00" + String(abs(numY))
        } else if numY < 10 {
            str = "00" + String(numY)
        } else {
            str = "0" + String(numY)
        }
        if abs(numX) == 100 {
            str += "," + String(numX)
        } else if numX < -9 && numX != -100 {
            str += ",-0" + String(abs(numX))
        } else if numX < 0 {
            str += ",-00" + String(abs(numX))
        } else if numX < 10 {
            str += ",00" + String(numX)
        } else {
            str += ",0" + String(numX)
        }
        return str
    }
    // Sending Data to Arduino
    func writeValue(_ data: String) {
        let myData = data.data(using: String.Encoding.utf8)
        if let peripheral = HM10_Module {
            let peripheralCharacteristic = peripheral.services![0].characteristics![0]
            //print(peripheralCharacteristic)
            peripheral.writeValue(myData!, for: peripheralCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            print("Sending Data: \(data)")
            //peripheralCharacteristic.isNotifying
        }
    }
}
