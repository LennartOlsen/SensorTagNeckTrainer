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
    
    let devices : [UUID : SensorTagPeripheral]
    
    let listenerDelegate : CollectorListenerDelegate!
    
    var dataEntry : DataEntry?
    
    var accelerometer : AccelerometerMeasurement?
    var gotNewAccelerometer = false
    var requiresAccelerometer = false
    var gyroscope : GyroscopeMeasurement?
    var gotNewGyroscope = false
    var requiresGyroscope = false
    var magnetometer : MagnetometerMeasurement?
    var gotNewMagnetometer = false
    var requiresMagnetometer = false
    
    var dataDelivered = [UUID : Measurement?]()
    
    private var count = 0
    
    init(devices : [UUID : SensorTagPeripheral], delegate : CollectorListenerDelegate?){
        self.devices = devices
        listenerDelegate = delegate
        
        for (uuid, device) in devices {
            device.attach(observer: self)
            dataDelivered[uuid] = nil
        }
    }
    
    
    func doCollect(count : Int, type : DataEntryTypes){
        dataEntry = DataEntry(type: type, id: UUID().uuidString)
        self.count = count
    }
    
    func checkAppend(_ m : Measurement, _ uuid : UUID){
        if count <= 0 {
            return
        }
        var good = true
        for dataTest in dataDelivered {
            if let d = dataTest.value {
                if let m = d as? AccelerometerMeasurement {
                    self.accelerometer = m
                }
                if let m = d as? MagnetometerMeasurement {
                    self.magnetometer = m
                }
                if let m = d as? GyroscopeMeasurement {
                    self.gyroscope = m
                }
            } else {
                good = false
            }
        }
        if( good ){
            self.dataEntry?.addMeasurement(accelerometer: self.accelerometer, magnetometer: self.magnetometer, gyroscope: self.gyroscope)
            
            for entity in dataDelivered {
                dataDelivered.updateValue(nil, forKey: entity.key)
            }
            
            self.count = self.count - 1;
            if(self.count == 0){
                listenerDelegate.collectionIsFinished(dataEntry: self.dataEntry!)
            }
        }
    }
    // make sure that collection is always stopped
    deinit {
        for (_,device) in devices {
            device.remove(observer: self)
        }
    }
}

extension Collector : SensorTagDelegate {
    
    var id: String {
        get {
            return "Collector"
        }
    }
    
    
    func Accelerometer(measurement: AccelerometerMeasurement, uuid : UUID) {
        accelerometer = measurement
        dataDelivered[uuid] = measurement
        checkAppend(measurement, uuid)
    }
    
    func Magnetometer(measurement: MagnetometerMeasurement, uuid : UUID) {
        magnetometer = measurement
        dataDelivered[uuid] = measurement
        checkAppend(measurement, uuid)
    }
    
    func Gyroscope(measurement: GyroscopeMeasurement, uuid : UUID) {
        gyroscope = measurement
        dataDelivered[uuid] = measurement
        checkAppend(measurement, uuid)
    }
    
    func Ready(uuid: UUID) {}
    
    func Errored(uuid: UUID) {}
    
    func ReadyForCalibration(uuid: UUID) {}
    
    func Calibrated(values: [[Double]], uuid: UUID) {}
    
    
}
