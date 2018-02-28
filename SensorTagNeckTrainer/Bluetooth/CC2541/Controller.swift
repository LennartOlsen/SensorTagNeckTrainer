//
//  Controller.swift
//  SensorTagRaider
//
//  Created by Lennart Olsen on 04/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//
// Inspired by (ripped of) : https://github.com/anasimtiaz/SwiftSensorTag

import Foundation


class Controller {
    
    private var xAccelerationCalibarationValue = 0.0, yAccelerationCalibarationValue = 0.0, zAccelerationCalibarationValue = 0.0
    
    private var xMagnetometerCalibarationValue = 0.0, yMagnetometerCalibarationValue = 0.0, zMagnetometerCalibarationValue = 0.0
    
    private var xGyroscopeCalibarationValue = 0.0, yGyroscopeCalibarationValue = 0.0, zGyroscopeCalibarationValue = 0.0
    
    
    // Convert NSData to array of bytes
    private func dataToSignedBytes16(value : NSData) -> [Int16] {
        let count = value.length
        var array = [Int16](repeating: 0, count: count)
        value.getBytes(&array, length:count * MemoryLayout<Int16>.size)
        return array
    }
    
    private func dataToUnsignedBytes16(value : NSData) -> [UInt16] {
        let count = value.length
        var array = [UInt16](repeating: 0, count: count)
        value.getBytes(&array, length:count * MemoryLayout<UInt16>.size)
        return array
    }
    
    private func dataToSignedBytes8(value : NSData) -> [Int8] {
        let count = value.length
        var array = [Int8](repeating: 0, count: count)
        value.getBytes(&array, length:count * MemoryLayout<Int8>.size)
        return array
    }
    
    // Get ambient temperature value
    func getAmbientTemperature(value : NSData) -> Double {
        let dataFromSensor = dataToSignedBytes16(value: value)
        let ambientTemperature = Double(dataFromSensor[1])/128
        return ambientTemperature
    }
    
    func getAccelerometerData(value: NSData) -> AccelerometerMeasurement {
        let dataFromSensor = dataToSignedBytes8(value: value)
        let xVal = Double(dataFromSensor[0]) / 64
        let yVal = Double(dataFromSensor[1]) / 64
        let zVal = Double(dataFromSensor[2]) / 64 * -1
        let measurement = AccelerometerMeasurement(xVal + xAccelerationCalibarationValue,
                                                   yVal + yAccelerationCalibarationValue,
                                                   zVal + zAccelerationCalibarationValue)
        return measurement
    }
    
    func getMagnetometerData(value: NSData) -> MagnetometerMeasurement {
        let dataFromSensor = dataToSignedBytes16(value: value)
        let xVal = Double(dataFromSensor[0]) * 2000 / 65536 * -1
        let yVal = Double(dataFromSensor[1]) * 2000 / 65536 * -1
        let zVal = Double(dataFromSensor[2]) * 2000 / 65536
        let measurement = MagnetometerMeasurement(xVal + xMagnetometerCalibarationValue,
                                                  yVal + yMagnetometerCalibarationValue,
                                                  zVal + zMagnetometerCalibarationValue)
        return measurement
    }
    
    func getGyroscopeData(value: NSData) -> GyroscopeMeasurement {
        let dataFromSensor = dataToSignedBytes16(value: value)
        let yVal = Double(dataFromSensor[0]) * 500 / 65536 * -1
        let xVal = Double(dataFromSensor[1]) * 500 / 65536
        let zVal = Double(dataFromSensor[2]) * 500 / 65536
        let measurement = GyroscopeMeasurement(xVal + xGyroscopeCalibarationValue,
                                                  yVal + yGyroscopeCalibarationValue,
                                                  zVal + zGyroscopeCalibarationValue)
        return measurement
    }
    
    func setCalibration(accelValue : [Double], magnetoValue : [Double], gyroValue : [Double]){
        xAccelerationCalibarationValue  = accelValue[0] * -1
        yAccelerationCalibarationValue  = accelValue[1] * -1
        zAccelerationCalibarationValue  = accelValue[2] * -1
        
        xMagnetometerCalibarationValue  = magnetoValue[0] * -1
        yMagnetometerCalibarationValue  = magnetoValue[1] * -1
        zMagnetometerCalibarationValue  = magnetoValue[2] * -1
        
        xGyroscopeCalibarationValue     = gyroValue[0] * -1
        yGyroscopeCalibarationValue     = gyroValue[1] * -1
        zGyroscopeCalibarationValue     = gyroValue[2] * -1
    }
    
    func getCalibrationValues() -> [[Double]] {
        return [
            [xAccelerationCalibarationValue, yAccelerationCalibarationValue, zAccelerationCalibarationValue],
            [xMagnetometerCalibarationValue, yMagnetometerCalibarationValue, zMagnetometerCalibarationValue],
            [xGyroscopeCalibarationValue, yGyroscopeCalibarationValue, zGyroscopeCalibarationValue],
        ]
    }
}
