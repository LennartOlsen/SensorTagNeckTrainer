//
//  Measurement.swift
//  SensorTagRaiderMacOS
//
//  Created by Lennart Olsen on 20/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

class Measurement {
    let x, y, z : Double
    
    init(_ X : Double,_ Y : Double , _ Z : Double){
        self.x = X
        self.y = Y
        self.z = Z
    }
    
    /**
     does this measurement eaxctly equal the one provided ie. x == x, y == y, z == z
     
     - parameter measurement: The measurement to compare to
     
     - returns: (x == x, y == y, z == z) true || false
     */
    func isEqualTo(_ measurement : Measurement) -> Bool {
        if(measurement.x == x && measurement.y == y && measurement.z == measurement.z){
            return true
        }
        return false
    }
}

class AccelerometerMeasurement : Measurement { }

class MagnetometerMeasurement : Measurement { }

class GyroscopeMeasurement : Measurement { }

class MeasurementCollection {
    
    var measurements : [Measurement] = []
    
    let timeStamp : Int
    
    init(accelerometer : AccelerometerMeasurement, magnetometer : MagnetometerMeasurement, gyroscope : GyroscopeMeasurement, _ timeStamp : Int? = nil){
        measurements.append(accelerometer)
        measurements.append(magnetometer)
        measurements.append(gyroscope)
        if let ts = timeStamp{
            self.timeStamp = ts
        } else {
            self.timeStamp = Int(Date().timeIntervalSince1970)
        }
    }
    
    /**
    Gets the measurements as an array of doubles
     
     - returns : [accX,accY,accZ,magnetX,magnetY,magnetZ,gyroX,gyroY,gyroZ]
     */
    func asArray() -> [Double] {
        var arr : [Double] = [Double](repeating: 0, count: 9)
        for measurement in measurements {
            if measurement is AccelerometerMeasurement {
                arr[0] = measurement.x
                arr[1] = measurement.y
                arr[2] = measurement.z
            }
            if measurement is MagnetometerMeasurement {
                arr[3] = measurement.x
                arr[4] = measurement.y
                arr[5] = measurement.z
            }
            if measurement is GyroscopeMeasurement {
                arr[6] = measurement.x
                arr[7] = measurement.y
                arr[8] = measurement.z
            }
        }
        return arr
    }
}
