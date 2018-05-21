//
//  BaselineComparator.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 26/03/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

class BaselineComparator : ObserverPattern {
    private let maxMeasurements = 3
    
    private let baselines : [Baseline]
    private let device : SensorTagPeripheral
    
    private var measurements = [Measurement]()
    
    init(baselines : [Baseline], device : SensorTagPeripheral){
        self.baselines = baselines
        self.device = device
        super.init()
        self.device.attach(observer: self)
    }
    
    private func addMeasurement(_ measurement : MagnetometerMeasurement){
        if(measurements.count > maxMeasurements - 1){
            measurements.remove(at: 0)
        }
        
        measurements.append(measurement)
        self.calculateBaseline()
    }
    
    func calculateBaseline() {
        for b in self.baselines {
            for m in measurements {
                if(b.isMeasurementWithin(m.x,m.y,m.z)){
                    self.notify(type: b.type)
                }
            }
        }
    }
    
    private func notify(type : DataEntryTypes){
        for o in observers as! [BaselineComparatorDelegate] {
            o.gotType(type)
        }
    }
    
    deinit{
        self.device.remove(observer: self)
    }
}

extension BaselineComparator : ObserverProtocol {
    var id: String {
        get {
            return "BaselineComparator"
        }
    }
}

extension BaselineComparator : SensorTagDelegate {
    func Magnetometer(measurement: MagnetometerMeasurement, uuid : UUID) {
        self.addMeasurement(measurement)
    }
    
    func Ready(uuid : UUID) {}
    func Errored(uuid : UUID) {}
    func Accelerometer(measurement: AccelerometerMeasurement, uuid : UUID) {}
    func Gyroscope(measurement: GyroscopeMeasurement, uuid : UUID) {}
    func ReadyForCalibration(uuid : UUID) {}
    func Calibrated(values: [[Double]], uuid : UUID) {}
}
