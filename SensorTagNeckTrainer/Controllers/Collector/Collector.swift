//
//  Collector.swift
//  SensorTagRaiderMacOS
//
//  Created by Lennart Olsen on 12/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

class Collector {
    
    var timer: DispatchSourceTimer?
    
    let device : SensorTagPeripheral
    
    let listenerDelegate : CollectorListenerDelegate!
    
    var dataEntry : DataEntry?
    
    var accelerometer : AccelerometerMeasurement?
    var gyroscope : GyroscopeMeasurement?
    var magnetometer : MagnetometerMeasurement?
    
    init(device : SensorTagPeripheral, delegate : CollectorListenerDelegate?){
        self.device = device
        listenerDelegate = delegate
        
        device.attach(observer: self)
    }
    
    func doCollect(time : Double, type : DataEntryTypes){
        
        dataEntry = DataEntry(type: type, id: UUID().uuidString)
        
        let when =  DispatchTime.now() + time
        
        self.startMeasurementCollection()
        
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.stopMeasurementCollection()
            if let d = self.listenerDelegate {
                if let data = self.dataEntry {
                    self.accelerometer = nil
                    self.gyroscope = nil
                    self.magnetometer = nil
                    d.collectionIsFinished(dataEntry : data)
                }
            }
        }
        
    }
    
    func startMeasurementCollection(){
        let queue = DispatchQueue(label : "net.lennartolsen.SensorTagCollector.Collector")
        
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer!.schedule(deadline: .now() + .milliseconds(333), repeating: .milliseconds(333))
        timer!.setEventHandler { [weak self] in
            if let a = self?.accelerometer, let m = self?.magnetometer, let g = self?.gyroscope {
                self?.dataEntry?.addMeasurement(accelerometer: a,
                                                magnetometer: m,
                                                gyroscope: g)
            }
        }
        timer!.resume()
    }
    
    func stopMeasurementCollection() {
        timer?.cancel()
        timer = nil
    }
    
    // make sure that collection is always stopped
    deinit {
        stopMeasurementCollection()
    }
}

extension Collector : SensorTagDelegate {
    var id: String {
        get {
            return "Collector"
        }
    }
    
    
    func Accelerometer(measurement: AccelerometerMeasurement) {
        accelerometer = measurement
    }
    
    func Magnetometer(measurement: MagnetometerMeasurement) {
        magnetometer = measurement
    }
    
    func Gyroscope(measurement: GyroscopeMeasurement) {
        gyroscope = measurement
    }
    
    func Calibrated(values: [[Double]]) {}
    
    func Ready() {}
    
    func Errored() {}
    
    func ReadyForCalibration() {}
    
    
}
