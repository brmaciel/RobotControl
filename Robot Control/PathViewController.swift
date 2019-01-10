//
//  PathViewController.swift
//  My Robot
//
//  Created by Bruno Maciel on 11/24/16.
//  Copyright © 2016 Bruno Maciel. All rights reserved.
//

import UIKit

var myRobot = Path()

class PathViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var viewCanvas: UIView!
    @IBOutlet weak var fieldX: UITextField!
    @IBOutlet weak var fieldY: UITextField!
    @IBOutlet weak var lbScaleX: UILabel!
    @IBOutlet weak var lbScaleY: UILabel!
    
    @IBOutlet weak var lbPositions: UITextView!
    
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnClear: UIButton!
    
    @IBOutlet weak var viewEditPoints: UIView!
    @IBOutlet weak var viewTextEdit: UITextView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var fieldScaleX: UITextField!
    @IBOutlet weak var fieldScaleY: UITextField!
    
    @IBOutlet weak var viewResults: UIView!
    @IBOutlet weak var scrollAngles: UITextView!
    @IBOutlet weak var scrollDistance: UITextView!
    
    var pointsStored: String = ""
    var xPositions = [Double]()
    var yPositions = [Double]()
    
    var arrayPointsPositionsX = [CGFloat]()
    var arrayPointsPositionsY = [CGFloat]()
    
    var posDictionary = [String : Double]()
    var edPointsStored: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initializeLongPressGesture()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Close"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        navigationController?.tabBarController?.tabBar.isHidden = true
    }
    
    
    @IBAction func storePosition(_ sender: AnyObject) {
        for view in viewCanvas.subviews {     //delete the points created that were shown in canvas
            if view.backgroundColor == UIColor.green { view.removeFromSuperview()  }
        }
        if fieldX.text != "" && fieldY.text != "" {
            if Double(fieldX.text!) != nil && Double(fieldY.text!) != nil {     //guarantee the coordinate provided is a number
                let maxX = Double(lbScaleX.text!)!
                let maxY = Double(lbScaleY.text!)!
            
                if Double(fieldX.text!)! > maxX {  xPositions.insert(maxX, at: xPositions.count)    }
                else if Double(fieldX.text!)! < 0.0 {   xPositions.insert(0.0, at: xPositions.count)  }
                else {  xPositions.insert(Double(fieldX.text!)!, at: xPositions.count)    }
            
                if Double(fieldY.text!)! > maxY {  yPositions.insert(maxY, at: yPositions.count)    }
                else if Double(fieldY.text!)! < 0.0 {   yPositions.insert(0.0, at: yPositions.count)  }
                else {  yPositions.insert(Double(fieldY.text!)!, at: yPositions.count)    }
            
                fieldX.text = ""
                fieldY.text = ""
                pointsStored += "( \(xPositions[xPositions.count-1]) , \(yPositions[yPositions.count-1]) )\n"
                lbPositions.text = pointsStored
            
                setPointOnCanvas(viewCanvas, nPt:  yPositions.count)
            
                switch xPositions.count {
                case 1: btnEdit.isEnabled = true; break
                case 2: btnStart.isEnabled = true; break
                default: break
                }
            }
            else {  print("Error: coordinate is not a number")  }
        }
    }
    @IBAction func clearFieldXY(_ sender: Any) {
        fieldX.text = ""
        fieldY.text = ""
        for view in viewCanvas.subviews {     //delete the green points shown on canvas
            if view.backgroundColor == UIColor.green { view.removeFromSuperview()  }
        }
    }
    @IBAction func clearPath(_ sender: AnyObject) {   //reset all data stored
        //fieldX.text = ""
        //fieldY.text = ""
        xPositions = [Double]()
        yPositions = [Double]()
        pointsStored = ""
        lbPositions.text = "( x0 , y0 )"
        //myRobot = Path()
        //posDictionary = [ : ]
        for view in viewCanvas.subviews {     //delete the points created that are shown on canvas
            view.removeFromSuperview()
        }
        btnEdit.isEnabled = false
        btnStart.isEnabled = false
    }
    
    func initializeLongPressGesture() {
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(PathViewController.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.3
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        viewCanvas.addGestureRecognizer(lpgr)
    }
    
    func handleLongPress(_ gestureReconizer: UILongPressGestureRecognizer) {
        if (gestureReconizer.state == UIGestureRecognizerState.changed || gestureReconizer.state == UIGestureRecognizerState.began) {
            let p = gestureReconizer.location(in: self.viewCanvas)
            //print(p)
            let maxX = Double(lbScaleX.text!)!
            let maxY = Double(lbScaleY.text!)!
            
            var x = ((p.x * 100.0)/viewCanvas.frame.width)*(CGFloat(maxX)/100.0)
            var y = (100.0 - ( (p.y * 100.0)/viewCanvas.frame.height ))*((CGFloat(maxY)/100.0))
            if x>CGFloat(maxX) {  x = CGFloat(maxX) }
            else if x<0.0 {   x = 0.0 }
            if y>CGFloat(maxY) {   y = CGFloat(maxY) }
            else if y<0.0 {  y = 0.0 }
            
            fieldX.text = NSString(format: "%.2f", x) as String
            fieldY.text = NSString(format: "%.2f", y) as String
            
            let xx = ( (viewCanvas.frame.width - 3)/100.0 )*(x)/CGFloat((maxX/100))
            let yy = (viewCanvas.frame.height - 3)*( 1.0 - (y)/CGFloat((maxY/100))/100.0 )
            
            setTempPointOnCanvas(xx, y: yy)
        }
    }
    
    func setPointOnCanvas(_ canvas : UIView, nPt : Int) {
        let maxX = Double(lbScaleX.text!)!
        let maxY = Double(lbScaleY.text!)!
        
        let height: CGFloat = 3;
        let x = ( (canvas.frame.width - height)/100.0 )*CGFloat(xPositions[nPt-1]/(maxX/100))
        let y = (canvas.frame.height - height)*( 1.0 - CGFloat((yPositions[nPt-1])/(maxY/100))/100.0 )
        
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
    func setTempPointOnCanvas(_ x: CGFloat, y: CGFloat) {
        for view in viewCanvas.subviews {     //delete the points created that were shown in canvas
            if view.backgroundColor == UIColor.green { view.removeFromSuperview()  }
        }
        let point = CGRect(x: x, y: y, width: 3, height: 3)
        let pointView = UIView(frame: point)
        pointView.backgroundColor = UIColor.green
        viewCanvas.addSubview(pointView)
    }
    
    // Text Field function to close keyboard when touching the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
        
        if fieldX.text != "" && fieldY.text != "" {
            if Double(fieldX.text!) != nil && Double(fieldY.text!) != nil {     //guarantee the coordinate provided is a number
                let maxX = Double(lbScaleX.text!)!
                let maxY = Double(lbScaleY.text!)!
                var x = Double(fieldX.text!)!
                var y = Double(fieldY.text!)!
                
                if x>maxX {  x = maxX }
                else if x<0.0 { x = 0.0 }
                if y>maxY {  y = maxY }
                else if y<0.0 { y = 0.0 }
                
                let xx = ( (viewCanvas.frame.width - 3)/100.0 )*CGFloat(x)/CGFloat((maxX/100))
                let yy = (viewCanvas.frame.height - 3)*( 1.0 - CGFloat(y)/CGFloat((maxY/100))/100.0 )
                
                setTempPointOnCanvas(xx, y: yy)
            }
            else {  print("Error: coordinate is not a number")  }
        }
    }
    
    
    /**********        Functions of Results View        **********/
    @IBAction func startPath(_ sender: AnyObject) {
        myRobot.initRobotPath(xPositions, yPos: yPositions, xScale: lbScaleX.text!, yScale: lbScaleY.text!)

        viewResults.isHidden = false
        
        scrollAngles.text = myRobot.accessStepAngles()
        scrollDistance.text = myRobot.accessDistances()
        
        arrayPointsPositionsX = [CGFloat]()
        arrayPointsPositionsY = [CGFloat]()
    }
    @IBAction func closeResultsView(_ sender: AnyObject) {
        viewResults.isHidden = true
        //btnSimulate.enabled = true
    }
    
    
    /**********        Functions of Edit View        **********/
    @IBAction func editPath(_ sender: AnyObject) {
        createDictionary()
        initializeEditView()
    }
    @IBAction func cancelEdition(_ sender: AnyObject) {
        viewEditPoints.isHidden = true
    }
    @IBAction func saveEdition(_ sender: AnyObject) {
        btnCancel.isEnabled = false
        btnDone.isEnabled = true
        
        if Double(fieldScaleX.text!) != nil && Double(fieldScaleX.text!)! > 30.0 {     //guarantee the scaleX provided is a number
            lbScaleX.text = fieldScaleX.text!
        }
        if Double(fieldScaleY.text!) != nil && Double(fieldScaleY.text!)! > 30.0 {          //guarantee the scaleY provided is a number
            lbScaleY.text = fieldScaleY.text!
        }
        
        siftEditedData()
    }
    @IBAction func doneEdition(_ sender: AnyObject) {
        viewEditPoints.isHidden = true
        resetAllData()
    }
    
    func createDictionary(){
        for n in 0..<xPositions.count {
            posDictionary["x\(n+1)"] = xPositions[n]
            posDictionary["y\(n+1)"] = yPositions[n]
        }
    }
    func initializeEditView() {
        viewEditPoints.isHidden = false
        btnDone.isEnabled = false
        btnCancel.isEnabled = true
        
        viewTextEdit.text = ""
        fieldScaleX.text = lbScaleX.text
        fieldScaleY.text = lbScaleY.text
        
        // populate textView with positions
        edPointsStored = ""
        for n in 0..<posDictionary.count/2 {
            edPointsStored += "x\(n+1) : \(posDictionary["x\(n+1)"]!) , y\(n+1) : \(posDictionary["y\(n+1)"]!)\n"
        }
        viewTextEdit.text = edPointsStored
    }
    func siftEditedData() {      //pega o texto do textView e o transforma em uma matrix, contendo apenas os valores de keys e values pro dicionario
        var newText = String()
        
        //viewTextEdit tem o seguinte formato: "( x0 : vx0 ,  y0 : vy0 )\n( x1 : vx1 ,  y1 : vy1 )\n( x2 : vx2 ,  y2 : vy2 )\n"
        var myArray = viewTextEdit.text.components(separatedBy: "\n")
        for n in (0..<myArray.count).reversed() {
            if myArray[n].isEmpty { myArray.remove(at: n)   }   //caso exista elementos ""(vazios) na matrix, são excluidos
        }
        //print("Empty Lines corrected: \(myArray)")
        
        // cada linha da myArray tem seguinte formato: "( xn : vxn ,  yn : vyn )"
        for n in 0..<myArray.count {
            //alteracao (corrige caso xxyx4)
            var charNum = String(myArray[n][myArray[n].index(after: myArray[n].startIndex)])    //charNum = segundo caracter
            while !((myArray[n].hasPrefix("x") || myArray[n].hasPrefix("y")) && Int(charNum) != nil) {
                myArray[n].remove(at: myArray[n].startIndex)     //deleta os primeiros caracteres até que encontre o caracter "x" ou "y"
                charNum = String(myArray[n][myArray[n].index(after: myArray[n].startIndex)])    //e o segundo caracter seja um algarismo
            }
            
            var lastChar = String(myArray[n][myArray[n].index(before: myArray[n].endIndex)])    //lastChar = ultimo caracter
            while Int(lastChar) == nil {
                myArray[n].remove(at: myArray[n].index(before: myArray[n].endIndex)) //deleta os ultimos caracteres até que encontre
                lastChar = String(myArray[n][myArray[n].index(before: myArray[n].endIndex)])    //um algarismo
            }
            
            myArray[n].append(",")  //cada linha da myArray agora tem o seguinte formato: "xn : vxn , yn : vyn,"
            newText += myArray[n]     //newText tem o formato: "x0 : vx0 , y0 : vy0,x1 : vx1 , y1 : vy1,x2 : vx2 , y2 : vy2,"
        }
        //print("Start/End Line corrected: \(myArray)")
        //print(newText)
        
        myArray = newText.components(separatedBy: ",")
        myArray.removeLast()    //ultimo elemento da matrix é ""(vazio)
        //print(myArray)
        
        // cada linha da myArray tem seguinte formato: "x0 : vx0 " " y0 : vy0"
        newText = ""
        for n in 0..<myArray.count {
            var charNum = String(myArray[n][myArray[n].index(after: myArray[n].startIndex)])    //charNum = segundo caracter
            while !((myArray[n].hasPrefix("x") || myArray[n].hasPrefix("y")) && Int(charNum) != nil) {
                myArray[n].remove(at: myArray[n].startIndex)    //deleta os primeiros caracteres até que encontre o caracter "x" ou "y"
                charNum = String(myArray[n][myArray[n].index(after: myArray[n].startIndex)])    //e o segundo caracter seja um algarismo
            }
            var lastChar = String(myArray[n][myArray[n].index(before: myArray[n].endIndex)])
            while Int(lastChar) == nil {
                myArray[n].remove(at: myArray[n].index(before: myArray[n].endIndex)) //deleta os ultimos caracteres até que encontre
                lastChar = String(myArray[n][myArray[n].index(before: myArray[n].endIndex)])    //um algarismo
            }
            
            myArray[n].append(":")  //cada linha da myArray agora tem o seguinte formato: "xn : vxn:"
            newText += myArray[n]   //newText tem o formato: "x0 : vx0:y0 : vy0:x1 : vx1:y1 : vy1:x2 : vx2:y2 : vy2:"
        }
        //print(myArray)
        //print(newText)
        
        myArray = newText.components(separatedBy: ":")
        myArray.removeLast()    //ultimo elemento da matrix é ""(vazio)
        //print(myArray)
        
        // as linhas da myArray tem seguinte formato: "x0 " " vx0" "y0 " " vy0"
        for n in 0..<myArray.count {
            if n%2 != 0 {                   //indices impares são os valores
                var charNum = String(myArray[n][myArray[n].startIndex])     //deleta os primeiros caracteres até que encontre um algarismo
                while Int(charNum) == nil {
                    myArray[n].remove(at: myArray[n].startIndex)
                    charNum = String(myArray[n][myArray[n].startIndex])
                }
            } else {                        ////indices pares são as keys
                var lastChar = String(myArray[n][myArray[n].index(before: myArray[n].endIndex)])
                while !(Int(lastChar) != nil) {
                    myArray[n].remove(at: myArray[n].index(before: myArray[n].endIndex)) //deleta ultimos caracteres até que encontre
                    lastChar = String(myArray[n][myArray[n].index(before: myArray[n].endIndex)])    //um algarismo referente a key
                }
            }
        }
        //print(myArray)
        
        redefineDictionary(myArray)        //apos peneirar as informações, restando apenas os valores de keys e values, cria-se o dicionario
    }
    func redefineDictionary(_ myArray:[String]) {
        let maxX = Double(lbScaleX.text!)!
        let maxY = Double(lbScaleY.text!)!
        
        posDictionary = [ : ]
        var n=0
        while n < myArray.count {
            if n%4 == 0 {
                if Double(myArray[n+1])! > maxX {  posDictionary[myArray[n]] = maxX   }
                else if Double(myArray[n+1])! < 0.0 {   posDictionary[myArray[n]] = 0.0   }
                else {  posDictionary[myArray[n]] = Double(myArray[n+1])!   }
            } else {
                if Double(myArray[n+1])! > maxY {  posDictionary[myArray[n]] = maxY   }
                else if Double(myArray[n+1])! < 0.0 {   posDictionary[myArray[n]] = 0.0   }
                else {  posDictionary[myArray[n]] = Double(myArray[n+1])!   }
            }
            n+=2
        }
        
        //check if there is key missing and add value 0.0 for those missing keys
        let keyArray = [String](posDictionary.keys)
        var dicSize : Int = posDictionary.count/2
        for n in 0..<keyArray.count {
            var keyNum = keyArray[n]
            keyNum.remove(at: keyNum.startIndex)
            if dicSize < Int(keyNum)! { dicSize = Int(keyNum)! }
        }
        if dicSize != posDictionary.count/2 {
            updateDictionary(size: dicSize)
        }
    }
    func updateDictionary(size : Int) {
        for n in 1...size {
            if posDictionary["x\(n)"] == nil {
                posDictionary ["x\(n)"] = 0.0
            }
            if posDictionary["y\(n)"] == nil {
                posDictionary ["y\(n)"] = 0.0
            }
        }
    }
    func resetAllData() {
        xPositions = [Double]()
        yPositions = [Double]()
        pointsStored = ""
        lbPositions.text = ""
        //delete the points created that were shown in canvas
        for view in viewCanvas.subviews { view.removeFromSuperview()  }
        for n in 1...posDictionary.count/2 {
            xPositions.insert(posDictionary["x\(n)"]!, at: xPositions.count);
            yPositions.insert(posDictionary["y\(n)"]!, at: yPositions.count);
            pointsStored += "( \(xPositions[xPositions.count-1]) , \(yPositions[yPositions.count-1]) )\n"
            setPointOnCanvas(viewCanvas, nPt:  yPositions.count)
        }
        lbPositions.text = pointsStored
        
        print("Points Stored:\n\(pointsStored)")
    }
    
}
