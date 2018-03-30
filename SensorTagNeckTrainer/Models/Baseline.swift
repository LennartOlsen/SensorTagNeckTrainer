//
//  Baseline.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 16/03/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

class Baseline {
    var avgX,avgY,avgZ : Double!
    var minX,minY,minZ : Double!
    var maxX,maxY,maxZ : Double!
    let type : DataEntryTypes

    init(type : DataEntryTypes){
        self.type = type
    }
    
    func addValues(x : Double,y : Double, z : Double){
        avgX = (avgX ?? 0 + x) / 2
        avgY = (avgY ?? 0 + y) / 2
        avgZ = (avgZ ?? 0 + z) / 2
        
        setMin(x, y, z)
        setMax(x, y, z)
    }
    
    private func setMin(_ x : Double, _ y : Double, _ z : Double){
        /** Quite ineffective but pretty **/
        minX = minX ?? x
        minY = minY ?? y
        minZ = minZ ?? z
        
        minX = x < minX ? x : minX
        minY = y < minY ? y : minY
        minZ = z < minZ ? z : minZ
    }
    
    private func setMax(_ x : Double, _ y : Double, _ z : Double){
        /** Quite ineffective but pretty **/
        maxX = maxX ?? x
        maxY = maxY ?? y
        maxZ = maxZ ?? z
        
        maxX = x > maxX ? x : maxX
        maxY = y > maxY ? y : maxY
        maxZ = z > maxZ ? z : maxZ
    }
    
    
    func isMeasurementWithin(_ x : Double, _ y : Double, _ z : Double) -> Bool {
        let fitsX = x < maxX && x > minX
        let fitsY = y < maxY && y > minY
        let fitsZ = z < maxZ && z > minZ
        
        return fitsX && fitsY && fitsZ
    }
}
