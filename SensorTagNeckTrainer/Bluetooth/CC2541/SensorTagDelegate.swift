//
//  SensorTagDelegate.swift
//  SensorTagRaider
//
//  Created by Lennart Olsen on 04/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

protocol SensorTagDelegate: ObserverProtocol {
    func Ready()
    
    func Errored()
    
    func Accelerometer(measurement : AccelerometerMeasurement)
    
    func Magnetometer(measurement : MagnetometerMeasurement)
    
    func Gyroscope(measurement : GyroscopeMeasurement)
    
    func ReadyForCalibration()
    
    func Calibrated(values : [[Double]]) /** Accelerometer, magnetometer, Gyroscope, all x,y,z **/
}
