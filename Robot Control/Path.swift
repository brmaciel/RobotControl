//
//  Path.swift
//  My Robot
//
//  Created by Bruno Maciel on 11/24/16.
//  Copyright © 2016 Bruno Maciel. All rights reserved.
//

import Foundation

class Path {
    private var xPositions = [Double]()     //1D vector to store xPositions
    private var yPositions = [Double]()     //1D vector to store yPositions
    private var nPoints = Int()             //number of points
    private var scaleX = String()
    private var scaleY = String()
    
    private var rawAngle = [Double]()         //1D vector to store the angle of each line
    private var stepAngle = [Double]()          //1D vector to store the angles the robot must turn in every vertice
    private var distance = [Double]()      //1D vector to store the distance between vertices
    
    /**********        Public Functions for Path Data Access        **********/
    func accessStepAngles() -> String {
        var auxText = String()
        for n in 0..<stepAngle.count {
            auxText = auxText + (NSString(format: "%.1f", stepAngle[n]) as String) + "°\n"
        }
        return auxText
    }
    func accessDistances() -> String {
        var auxText = String()
        for n in 0..<distance.count {
            auxText += (n != distance.count-1 ? "p\(n+1)-p\(n+2):" : "p\(n+1)-p1:" )
            auxText += "    " + (NSString(format: "%.2f", distance[n]) as String) + " cm\n"
        }
        return auxText
    }
    
    /**********        Public Functions for Simulation Data Access        **********/
    func infoScaleX() -> String {   return scaleX   }
    func infoScaleY() -> String {   return scaleY   }
    func infoNumPoints() -> Int {   return nPoints  }
    func infoPosX(n: Int) -> Double {    return xPositions[n]    }
    func infoPosY(n: Int) -> Double {    return yPositions[n]    }
    func distance(_ index: Int) -> Double {  return distance[index]  }
    func stepAngle(_ index: Int) -> Double {  return stepAngle[index]  }
    func infoStepAng(_ index: Int) -> String {
        return NSString(format: "%.1f", stepAngle[index]) as String
    }
    func infoDistance(_ index: Int) -> String {
        return NSString(format: "%.2f", distance[index]) as String
    }
    
    
    /**********        Private Functions for Object Initialization        **********/
    func initRobotPath(_ xPos: [Double], yPos: [Double], xScale: String, yScale: String) {
        self.xPositions = xPos
        self.yPositions = yPos
        self.scaleX = xScale
        self.scaleY = yScale
        
        self.nPoints = xPos.count
        //print(nPoints)
        //print("x: \(xPositions)\ny: \(yPositions)")
        
        findPathProperties()
        printRobotInfo()
    }
    
    //find the angle of each line and the size of each line
    private func findPathProperties() {
        rawAngle = [Double]()
        stepAngle = [Double]()
        distance = [Double]()
        
        for n in 0..<nPoints {
            let m = ( (n+1)<nPoints ? n+1 : 0)      //if n is the last point, m will assume the first point
            rawAngle.append( findAngle(xPositions[n], y0: yPositions[n], x1: xPositions[m], y1: yPositions[m]) )
            distance.append( findDistance(xPositions[n], y0: yPositions[n], x1: xPositions[m], y1: yPositions[m]) )
        }
        //print("rawAngles: \(rawAngle)")
        //print("dist: \(distance)")
        
        //find the angle the robot shall turn as it gets to each vertice
        //we assume the robot starts every time at 90° (facing "north")
        if rawAngle[0] > 270 {      //if the 1st angle is between 270° and 360°, the robot turns from -90° up to -180° (clockwise)
            stepAngle.append(rawAngle[0]-360-90)
        } else {
            stepAngle.append(rawAngle[0]-90)
        }
        for n in 1..<nPoints {
            var deltaAngle: Double = -rawAngle[n-1]+rawAngle[n]
            if deltaAngle > 180 {
                deltaAngle -= 360
            } else if deltaAngle < -180 {
                deltaAngle += 360
            }
            //print(deltaAngle)
            stepAngle.append(deltaAngle)
        }
        if -rawAngle[rawAngle.count-1]+90 > 180
        {   stepAngle.append(-rawAngle[rawAngle.count-1]+90-360)    }
        else if -rawAngle[rawAngle.count-1]+90 < -180
        {   stepAngle.append(-rawAngle[rawAngle.count-1]+90+360)    }
        else
        {   stepAngle.append(-rawAngle[rawAngle.count-1]+90)    }
        
        // if the angle is negative, the robot turns clockwise
        // if the angle is positive, the robot turns counter-clockwise
        
        //print("stepAngle: \(stepAngle)")
    }
    //Function to find the angle the line "creates" from a parallel line to origin
    private func findAngle(_ x0 : Double, y0 : Double, x1 : Double, y1 : Double) -> Double {
        let deltaY = y1-y0
        let deltaX = x1-x0
        
        var angleRad = Double()
        var angle = 1.0
        
        if deltaY == 0 {                //linha horizontal -> angle == 0º ou 180º
            if deltaX >= 0 { angle = 0   }      // x1 > x0 -> angle == 0º
            else {  angle = 180 }
        } else if deltaX == 0 {         //linha vertical -> angle == 90º ou 270º
            if deltaY > 0 { angle = 90  }       // y2 > y1 -> angle == 90º
            else {  angle = 270 }
        } else {
            angleRad = atan(deltaY/deltaX)
            angle = angleRad*180/Double.pi
            angle = trunc(angle, precision: 1)
            
            //angulo no 2º ou 3º quadrante, acha-se angulo equivalente no 4º e 1º quadrante respectivamente
            if deltaX < 0 {     angle = angle + 180;     }
            //angulo no 4º quadrante, acha-se o angulo (-), logo soma-se 360 p/ obter angulo (+)
            else if deltaY < 0 {    angle = angle + 360     }
        }
        //print(angle)
        return angle
    }
    //Function to find the distance between two vertices
    private func findDistance(_ x0: Double, y0: Double, x1: Double, y1: Double) -> Double {
        let deltaX = x1-x0
        let deltaY = y1-y0
        var dist = sqrt( pow(deltaX, 2.0) + pow(deltaY, 2.0) )
        dist = trunc(dist, precision: 2)
        //print(dist)
        return dist
    }
    
    //truncate function
    private func trunc(_ num: Double, precision: Double) -> Double {
        var result: Double
        result = round(num*pow(10.0,precision))
        result = result/pow(10.0,precision)
        return result
    }
    
    private func printRobotInfo() {
        var x : String = "X: "
        var y : String = "Y: "
        var ang : String = "Angles: " + (NSString(format: "%.1f", stepAngle[0]) as String) + " | "
        var dist : String = "Distance: "
        
        for n in 0..<xPositions.count {
            x += NSString(format: "%.2f", xPositions[n]) as String + " | "
            y += NSString(format: "%.2f", yPositions[n]) as String + " | "
            ang += NSString(format: "%.1f", stepAngle[n+1]) as String + " | "
            dist += NSString(format: "%.2f", distance[n]) as String + " | "
        }
        print(x)
        print(y)
        print(ang)
        print(dist)
        print("\n")
    }
    
}
