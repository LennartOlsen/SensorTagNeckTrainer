//
//  PredictionCollector.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 01/04/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

class PredictionCollector : ObserverPattern {
    let devices : [UUID: SensorTagPeripheral]
    let window : Int
    
    var magnetometerMeasurements = [MagnetometerMeasurement]()
    var gyroscopeMeasurements = [GyroscopeMeasurement]()
    
    private var isPredicting = false
    
    let p = Predictor()
    
    init(devices : [UUID: SensorTagPeripheral], window : Int = 10){
        self.devices = devices
        self.window = window
        super.init()
        for (_,device) in devices {
            device.attach(observer: self)
        }
    }
    
    func startPrediction(){
        isPredicting = true
    }
    
    func checkMeasurement(_ measurement : Measurement, _ uuid : UUID){
        guard isPredicting else {
            return
        }
        
        if let m = measurement as? MagnetometerMeasurement {
            if(magnetometerMeasurements.count > window - 1){
                magnetometerMeasurements.remove(at: 0)
            }
            
            magnetometerMeasurements.append(m)
        }
        if let m = measurement as? GyroscopeMeasurement {
            if(gyroscopeMeasurements.count > window - 1){
                gyroscopeMeasurements.remove(at: 0)
            }
            
            gyroscopeMeasurements.append(m)
        }
        
        if(gyroscopeMeasurements.count == window && magnetometerMeasurements.count == window) {
            let de = DataEntry(type: .tiltLeft, id: "1234")
            for i in 0...magnetometerMeasurements.count - 1 {
                if ( magnetometerMeasurements[i] == nil ){
                    print("Got nil magnetometerMeasurement @ \(i)")
                }
                if ( gyroscopeMeasurements[i] == nil ){
                    print("Got nil gyroscopeMeasurements @ \(i)")
                }
                de.addMeasurement(accelerometer: nil,
                                  magnetometer: magnetometerMeasurements[i],
                                  gyroscope: gyroscopeMeasurements[i])
            }
            
            if let v = p.PerformPrediction(dataEntry: de) {
                for d in observers as! [PredictionCollectorDelegate] {
                    d.prediction(output: v)
                }
            }
        }
    }
    
    deinit {
        for(_, device) in devices {
            device.remove(observer: self)
        }
    }
}

extension PredictionCollector : SensorTagDelegate {
    func Ready(uuid: UUID) {}
    
    func Errored(uuid: UUID) {}
    
    func Accelerometer(measurement: AccelerometerMeasurement, uuid: UUID) {}
    
    func Magnetometer(measurement: MagnetometerMeasurement, uuid: UUID) {
        checkMeasurement(measurement, uuid)
    }
    
    func Gyroscope(measurement: GyroscopeMeasurement, uuid: UUID) {
        checkMeasurement(measurement, uuid)
    }
    
    func ReadyForCalibration(uuid: UUID) {}
    
    func Calibrated(values: [[Double]], uuid: UUID) {}
    
    var id: String {
        get {
            return "PredictionCollector"
        }
    }
}
