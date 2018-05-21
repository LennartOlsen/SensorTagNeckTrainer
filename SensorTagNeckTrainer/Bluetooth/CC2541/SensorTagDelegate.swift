//
//  SensorTagDelegate.swift
//  SensorTagRaider
//
//  Created by Lennart Olsen on 04/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

protocol SensorTagDelegate: ObserverProtocol {
    func Ready(uuid: UUID)
    
    func Errored(uuid: UUID)
    
    func Accelerometer(measurement : AccelerometerMeasurement, uuid : UUID)
    
    func Magnetometer(measurement : MagnetometerMeasurement, uuid : UUID)
    
    func Gyroscope(measurement : GyroscopeMeasurement, uuid : UUID)
    
    func ReadyForCalibration(uuid: UUID)
    
    func Calibrated(values : [[Double]], uuid : UUID) /** Accelerometer, magnetometer, Gyroscope, all x,y,z **/
}
