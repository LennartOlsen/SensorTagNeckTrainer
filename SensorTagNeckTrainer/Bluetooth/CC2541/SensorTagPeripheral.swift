//
//  Device.swift
//  SensorTagRaider
//
//  Created by Lennart Olsen on 04/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation
import CoreBluetooth

let SENSORTAG_DEVICE_NAMES = [
    "TI BLE Sensor Tag", //iphone se
    "SensorTag" //Macos, ipad, iphone 7
]

enum SensorTagError: Error {
    case InvalidDevice
}

class SensorTagPeripheral : BaseBluetoothPeripheral {
    
    private var enableGyroValue = 7
    private var enablGyroBytes : NSData
    
    private var fastUpdate = 10 /** [input] * 10ms = 25 * 10ms = 250ms **/
    private var fastUpdateBytes : NSData
    
    private let D = false
    
    private var latestGyro : GyroscopeMeasurement? 
    private var latestMagneto : MagnetometerMeasurement?
    private var latestAcell : AccelerometerMeasurement?
    
    private var requestedAccelerometer = false
    private var requestedGyroscope = false
    private var requestedMagenetometer = false
    
    var ready = false
    
    let controller = Controller()
    
    init(device: CBPeripheral) {
        self.enablGyroBytes = NSData(bytes: &enableGyroValue, length: MemoryLayout<UInt8>.size)
        self.fastUpdateBytes = NSData(bytes: &fastUpdate, length : MemoryLayout<UInt8>.size)
        super.init(peripheral : device,
                   validCharacteristics: SENSORTAG_CHARACTERISTICS.array,
                   validServices: SENSORTAG_SERVICES.array,
                   noCharacteristServices: SENSORTAG_SERVICES.NO_CHARACTERISTICS_ARRAY)
        super.peripheral.delegate = self
    }
    
    static func validateSensorTag(device : CBPeripheral) -> Bool {
        if let n = device.name {
            return SENSORTAG_DEVICE_NAMES.contains(n)
        }
        return false
    }
    
    func calibrate(){
        let accel = latestAcell ?? AccelerometerMeasurement(0,0,0)
        let gyro = latestGyro ?? GyroscopeMeasurement(0,0,0)
        let magneto = latestMagneto ?? MagnetometerMeasurement(0,0,0)
        
        controller.setCalibration(accelValue: [accel.x,accel.y,accel.z],
                                  magnetoValue: [magneto.x,magneto.y,magneto.z],
                                  gyroValue: [gyro.x,gyro.y,gyro.z])
        
        for observer in super.observers() {
            observer.Calibrated(values: controller.getCalibrationValues())
        }
    }
    
    func readyForCalibration() -> Bool{
        let accOk = requestedAccelerometer ? latestAcell != nil : latestAcell == nil
        let gyroOk = requestedGyroscope ? latestGyro != nil : latestGyro == nil
        let magnetoOk = requestedMagenetometer ? latestMagneto != nil : latestMagneto == nil
        
        return accOk && gyroOk && magnetoOk
    }
}

extension SensorTagPeripheral : CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let e = error{
            print("Got error from service discovery", e)
        } else {
            super.handleDidDiscoverService(peripheral: peripheral)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if(D){print("PeripheralDiscoverer: didDiscoverCharacteristicsForService")}
        if super.handleDidDiscoverCharacteristic(peripheral: peripheral, service : service) {
            
            for observer in super.observers() {
                observer.Ready()
            }
            ready = true
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) { /** We only listen to characteristics **/ }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if(D){print("PeripheralDiscoverer: didUpdateValueForCharacteristic")}
        
        if(error == nil){
            if characteristic.uuid == SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_ACCELEROMETER_DATA {
                latestAcell = controller.getAccelerometerData(value: characteristic.value! as NSData )
                
                for observer in super.observers() {
                    observer.Accelerometer(measurement: latestAcell!)
                }
            }
            if characteristic.uuid == SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_MAGNETOMETER_DATA {
                latestMagneto = controller.getMagnetometerData(value: characteristic.value! as NSData )
                
                for observer in super.observers() {
                    observer.Magnetometer(measurement: latestMagneto!)
                }
            }
            if characteristic.uuid == SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_GYROSCOPE_DATA {
                latestGyro = controller.getGyroscopeData(value: characteristic.value! as NSData )
                for observer in super.observers() {
                    observer.Gyroscope(measurement: latestGyro!)
                }
            }
            if(readyForCalibration()){
                for observer in super.observers() {
                    observer.ReadyForCalibration()
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if(D){print("PeripheralDiscoverer: didUpdateNotificationStateForCharacteristic charac=\(characteristic.uuid.uuidString) isNotifying=\(characteristic.isNotifying)")}
    }
}


extension SensorTagPeripheral {
    
    func listenForAccelerometer() {
        if services[SENSORTAG_SERVICES.TI_SENSORTAG_ACCELEROMETER_SERVICE.uuidString] != nil && !requestedAccelerometer {
            
            if let configCharacteristic = characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_ACCELEROMETER_CONFIG.uuidString] {
                super.peripheral.writeValue(super.enablyBytes as Data, for: configCharacteristic, type: .withResponse)
                requestedAccelerometer = true
                
                if let dataCharacteristic = characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_ACCELEROMETER_DATA.uuidString] {
                    super.peripheral.setNotifyValue(true, for: dataCharacteristic)
                }
                
                if let periodCharacteristic = characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_ACCELEROMETER_PERIOD.uuidString] {
                    super.peripheral.writeValue(fastUpdateBytes as Data, for: periodCharacteristic, type: .withResponse)
                }
            }
        }
    }
    
    func listenForGyroscope(){
        if services[SENSORTAG_SERVICES.TI_SENSORTAG_GYROSCOPE_SERVICE.uuidString] != nil && !requestedGyroscope{
            
            
            if let configCharacteristic = characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_GYROSCOPE_CONFIG.uuidString] {
                super.peripheral.writeValue(enablGyroBytes as Data, for: configCharacteristic, type: .withResponse)
                requestedGyroscope = true
                
                if let dataCharacteristic = characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_GYROSCOPE_DATA.uuidString] {
                    super.peripheral.setNotifyValue(true, for: dataCharacteristic)
                }
                
                if let periodCharacteristic = characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_GYROSCOPE_PERIOD.uuidString] {
                    super.peripheral.writeValue(fastUpdateBytes as Data, for: periodCharacteristic, type: .withResponse)
                }
            }
            
        }
    }
    
    func listenForMagnetometer(){
        if services[SENSORTAG_SERVICES.TI_SENSORTAG_MAGNETOMETER_SERVICE.uuidString] != nil && !requestedMagenetometer {
            
            if let configCharacteristic = characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_MAGNETOMETER_CONFIG.uuidString] {
                super.peripheral.writeValue(super.enablyBytes as Data, for: configCharacteristic, type: .withResponse)
                requestedMagenetometer = true
                
                if let dataCharacteristic = characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_MAGNETOMETER_DATA.uuidString] {
                    super.peripheral.setNotifyValue(true, for: dataCharacteristic)
                }
                
                if let periodCharacteristic = characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_MAGNETOMETER_PERIOD.uuidString] {
                    super.peripheral.writeValue(fastUpdateBytes as Data, for: periodCharacteristic, type: .withResponse)
                }
            }
            
        }
    }
}
