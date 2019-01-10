//
//  SimulationViewController.swift
//  My Robot
//
//  Created by Bruno Maciel on 2/12/17.
//  Copyright © 2017 Bruno Maciel. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController {
    
    @IBOutlet weak var simulationCanvas: UIView!
    @IBOutlet weak var lbScaleX: UILabel!
    @IBOutlet weak var lbScaleY: UILabel!
    
    @IBOutlet weak var btnGO: UIButton!
    @IBOutlet weak var btnShow: UIButton!
    @IBOutlet weak var lbStepInfo1: UILabel!
    @IBOutlet weak var lbStepInfo2: UILabel!
    
    var arrayPointsPositionsX = [CGFloat]()
    var arrayPointsPositionsY = [CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.navigationController?.navigationBar.barTintColor = UIColor(red: 30/255, green: 29/255, blue: 28/255, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 40/255, green: 39/255, blue: 38/255, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.isNavigationBarHidden = true
        //self.tabBarController?.tabBar.isHidden = true
        
        btnGO.isEnabled = false
    }
    override func viewDidAppear(_ animated: Bool) {
        sleep(1)
        initializeView()
        initializeCanvas()
        btnGO.isEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func prepareForClose(_ sender: Any) {
        if btnShow.currentTitle == "Back" {
            self.navigationController?.isNavigationBarHidden = false
            btnShow.setTitle("Cancel", for: .normal)
        } else {
            self.navigationController?.isNavigationBarHidden = true
            btnShow.setTitle("Back", for: .normal)
        }
        
    }
    @IBAction func startSimulation(_ sender: Any) {
        btnGO.isEnabled = false
        for subview in simulationCanvas.subviews {
            if let img = subview as? UIImageView {
                img.removeFromSuperview()
            }
        }
        
        let imgDirection = UIImageView(frame: CGRect(x: 0,y: 0, width: 20, height: 20))
        imgDirection.center = CGPoint(x: arrayPointsPositionsX[0]+1.5, y: arrayPointsPositionsY[0])
        imgDirection.image = UIImage(named: "directionW")
        simulationCanvas.addSubview(imgDirection)
        
        doSimulation(n: 0, img: imgDirection, angSum: 0)
    }
    
    func initializeView() {
        arrayPointsPositionsX = [CGFloat]()
        arrayPointsPositionsY = [CGFloat]()
        
        lbScaleX.text = myRobot.infoScaleX()
        lbScaleY.text = myRobot.infoScaleY()
        
        lbStepInfo1.text = "\(myRobot.infoStepAng(0))º"
        lbStepInfo2.text = "\(myRobot.infoDistance(0)) cm"
    }
    func initializeCanvas() {
        //wait a time
        for n in 1...myRobot.infoNumPoints() {
            setPointOnSimuCanvas(simulationCanvas, nPt: n)
        }
    }
    
    func setPointOnSimuCanvas(_ canvas : UIView, nPt : Int) {
        let maxX = Double(lbScaleX.text!)!
        let maxY = Double(lbScaleY.text!)!
        
        let xPos = myRobot.infoPosX(n: nPt-1)
        let yPos = myRobot.infoPosY(n: nPt-1)
        
        let height: CGFloat = 3;
        let x = ( (canvas.frame.width - height)/100.0 )*CGFloat(xPos/(maxX/100))
        let y = (canvas.frame.height - height)*( 1.0 - CGFloat((yPos)/(maxY/100))/100.0 )
        
        arrayPointsPositionsX.append(x)
        arrayPointsPositionsY.append(y)
        
        let point = CGRect(x: x, y: y, width: height, height: height)
        let pointView = UIView(frame: point)
        pointView.backgroundColor = UIColor.white
        canvas.addSubview(pointView)
        
        let pointLabel = UILabel(frame: CGRect(x: 0,y: 0,width: 15,height: 10))
        pointLabel.center = CGPoint(x: x+4, y: y-4)
        pointLabel.textAlignment = NSTextAlignment.center
        pointLabel.text = "\(nPt)"
        pointLabel.textColor = UIColor.red
        pointLabel.font = UIFont(name: pointLabel.font.fontName, size: 10)
        canvas.addSubview(pointLabel)
    }
    
    func doSimulation(n: Int, img: UIImageView, angSum : Double) {
        let m = n+1
        let velocity = 50.0 //(cm/s)
        let angVelocity = 45.0//(º/s)
        
        let tempo = (m <= arrayPointsPositionsX.count ? myRobot.distance(n)/velocity : 0.0)
        let tempoAng = (myRobot.stepAngle(n) >= 0 ? myRobot.stepAngle(n)/angVelocity : -myRobot.stepAngle(n)/angVelocity)
        //print("T, TA[\(n)]=: \(tempo), \(tempoAng)")
        
        if m < arrayPointsPositionsX.count {
            let finalPoint = CGPoint(x: self.arrayPointsPositionsX[m]+1.5, y: self.arrayPointsPositionsY[m])
            let angle = (myRobot.stepAngle(n)) * (Double.pi/180.0) + angSum
            //let angle = atan( Double(viewCanvas.frame.width/viewCanvas.frame.height) * tan((myRobot.steps(n)) * (M_PI/180.0)) ) + angSum
            
            lbStepInfo1.text = "\(myRobot.infoStepAng(m-1))º"
            lbStepInfo2.text = "\(myRobot.infoDistance(m-1)) cm"
            
            UIView.animate(withDuration: tempoAng,
                                       animations: {img.transform = CGAffineTransform( rotationAngle: CGFloat(-angle) ) },
                                       completion: {(finished:Bool) in
                                        self.lbStepInfo1.text = "\(myRobot.infoDistance(m-1)) cm"
                                        self.lbStepInfo2.text = "\(myRobot.infoStepAng(m))º"
                                        UIView.animate(withDuration: tempo, delay: 0.2,
                                                                   options: UIViewAnimationOptions.curveEaseOut,
                                                                   animations: {img.center = finalPoint},
                                                                   completion: {(finished:Bool) in self.doSimulation(n: m, img: img, angSum: angle)} ) })
            
        } else if m == arrayPointsPositionsX.count {
            let finalPoint = CGPoint(x: self.arrayPointsPositionsX[0]+1.5, y: self.arrayPointsPositionsY[0])
            let angle = (myRobot.stepAngle(n)) * (Double.pi/180.0) + angSum
            //let angle = atan( Double(viewCanvas.frame.width/viewCanvas.frame.height) * tan((myRobot.steps(n)) * (M_PI/180.0)) ) + angSum
            
            lbStepInfo1.text = "\(myRobot.infoStepAng(m-1))º"
            lbStepInfo2.text = "\(myRobot.infoDistance(m-1)) cm"
            
            UIView.animate(withDuration: tempoAng,
                                       animations: {img.transform = CGAffineTransform( rotationAngle: CGFloat(-angle) ) },
                                       completion: {(finished:Bool) in
                                        self.lbStepInfo1.text = "\(myRobot.infoDistance(m-1)) cm"
                                        self.lbStepInfo2.text = "\(myRobot.infoStepAng(m))º"
                                        UIView.animate(withDuration: tempo, delay: 0.2,
                                                                   options: UIViewAnimationOptions.curveEaseOut,
                                                                   animations: {img.center = finalPoint},
                                                                   completion: {(finished:Bool) in self.doSimulation(n: m, img: img, angSum: angle)} ) })
        } else if m == arrayPointsPositionsX.count+1 {
            let angle = (myRobot.stepAngle(n)) * (Double.pi/180.0) + angSum
            //let angle = atan( Double(viewCanvas.frame.width/viewCanvas.frame.height) * tan((myRobot.steps(n)) * (M_PI/180.0)) ) + angSum
            
            lbStepInfo1.text = "\(myRobot.infoStepAng(m-1))º"
            lbStepInfo2.text = ""
            
            UIView.animate(withDuration: tempoAng, animations: {img.transform = CGAffineTransform( rotationAngle: CGFloat(-angle) ) },
                           completion: {(finished:Bool) in self.btnGO.isEnabled = true})
            //btnGO.isEnabled = true
        }
    }
}
