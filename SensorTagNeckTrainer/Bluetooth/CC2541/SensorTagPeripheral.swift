//
//  Device.swift
//  SensorTagRaider
//
//  Created by Lennart Olsen on 04/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation
import CoreBluetooth

let DEVICE_NAMES = [
    "TI BLE Sensor Tag", //iphone se
    "SensorTag" //Macos, ipad, iphone 7
]

enum SensorTagError: Error {
    case InvalidDevice
}

class SensorTagPeripheral : NSObject {
    private let sensorTag : CBPeripheral
    
    private var enableValue = 1
    private var enableGyroValue = 7
    private var enablyBytes : NSData
    private var enablGyroBytes : NSData
    
    private var fastUpdate = 25 /** [input] * 10ms = 10 * 10ms = 100ms **/
    private var fastUpdateBytes : NSData
    
    private let D = false
    
    private var services = [String : CBService]()
    private var characteristics = [String: CBCharacteristic]()
    
    private var latestGyro : GyroscopeMeasurement?
    private var latestMagneto : MagnetometerMeasurement?
    private var latestAcell : AccelerometerMeasurement?
    
    var ready = false
    
    var sensorTagDelegate : SensorTagDelegate?
    
    let controller = Controller()
    
    init(device: CBPeripheral) {
        self.sensorTag = device
        self.enablyBytes = NSData(bytes: &enableValue, length: MemoryLayout<UInt8>.size)
        self.enablGyroBytes = NSData(bytes: &enableGyroValue, length: MemoryLayout<UInt8>.size)
        self.fastUpdateBytes = NSData(bytes: &fastUpdate, length : MemoryLayout<UInt8>.size)
        super.init()
        self.sensorTag.delegate = self
    }
    
    static func validateSensorTag(device : CBPeripheral) -> Bool {
        if let n = device.name {
            return DEVICE_NAMES.contains(n)
        }
        return false
    }
    
    func setup(){
        sensorTag.discoverServices(nil)
    }
    
    func calibrate(){
        if let accel = latestAcell, let gyro = latestGyro, let magneto = latestMagneto {
            controller.setCalibration(accelValue: [accel.x,accel.y,accel.z],
                                      magnetoValue: [magneto.x,magneto.y,magneto.z],
                                      gyroValue: [gyro.x,gyro.y,gyro.z])
            sensorTagDelegate?.Calibrated(values : controller.getCalibrationValues())
        }
    }
    
    func readyForCalibration() -> Bool{
        return latestAcell != nil && latestGyro != nil && latestMagneto != nil
    }
    
    func addCharateristic(_ characteristic : CBCharacteristic) -> Bool {
        if(validCharacteristic(uuid : characteristic.uuid)){
            characteristics[characteristic.uuid.uuidString] = characteristic
            return true
        }
        return false
    }
    
    func addService(_ service : CBService) -> Bool {
        if(validService(uuid : service.uuid)){
            services[service.uuid.uuidString] = service
            return true
        }
        return false
    }
    
    func getDevice() -> CBPeripheral {
        return sensorTag
    }
}

extension SensorTagPeripheral {
    
    func listenForAccelerometer() {
        if self.services[SENSORTAG_SERVICES.TI_SENSORTAG_ACCELEROMETER_SERVICE.uuidString] != nil {
            
            if let configCharacteristic = self.characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_ACCELEROMETER_CONFIG.uuidString] {
                sensorTag.writeValue(enablyBytes as Data, for: configCharacteristic, type: .withResponse)
                
                if let dataCharacteristic = self.characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_ACCELEROMETER_DATA.uuidString] {
                    sensorTag.setNotifyValue(true, for: dataCharacteristic)
                }
                
                if let periodCharacteristic = self.characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_ACCELEROMETER_PERIOD.uuidString] {
                    sensorTag.writeValue(fastUpdateBytes as Data, for: periodCharacteristic, type: .withResponse)
                }
            }
        }
    }
    
    func listenForGyroscope(){
        if self.services[SENSORTAG_SERVICES.TI_SENSORTAG_GYROSCOPE_SERVICE.uuidString] != nil {
            
            
            if let configCharacteristic = self.characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_GYROSCOPE_CONFIG.uuidString] {
                sensorTag.writeValue(enablGyroBytes as Data, for: configCharacteristic, type: .withResponse)
                
                if let dataCharacteristic = self.characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_GYROSCOPE_DATA.uuidString] {
                    sensorTag.setNotifyValue(true, for: dataCharacteristic)
                }
                
                if let periodCharacteristic = self.characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_GYROSCOPE_PERIOD.uuidString] {
                    sensorTag.writeValue(fastUpdateBytes as Data, for: periodCharacteristic, type: .withResponse)
                }
            }
            
        }
    }
    
    func listenForMagnetometer(){
        if self.services[SENSORTAG_SERVICES.TI_SENSORTAG_MAGNETOMETER_SERVICE.uuidString] != nil {
            
            if let configCharacteristic = self.characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_MAGNETOMETER_CONFIG.uuidString] {
                sensorTag.writeValue(enablyBytes as Data, for: configCharacteristic, type: .withResponse)
                
                if let dataCharacteristic = self.characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_MAGNETOMETER_DATA.uuidString] {
                    sensorTag.setNotifyValue(true, for: dataCharacteristic)
                }
                
                if let periodCharacteristic = self.characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_MAGNETOMETER_PERIOD.uuidString] {
                    sensorTag.writeValue(fastUpdateBytes as Data, for: periodCharacteristic, type: .withResponse)
                }
            }
            
        }
    }
}

extension SensorTagPeripheral : CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service:CBService in peripheral.services!{
            if(addService(service)){
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if(D){print("PeripheralDiscoverer: didDiscoverCharacteristicsForService")}
        
        for c:CBCharacteristic in service.characteristics!{
            _ = addCharateristic(c)
        }
       
        //Determine if charasteristics for all services has been discovered
        var allCharacteristicsDiscovered = true
        for service:CBService in peripheral.services!{
            if service.characteristics == nil &&
                !SENSORTAG_SERVICES.NO_CHARACTERISTICS_ARRAY.contains(service.uuid) {
                allCharacteristicsDiscovered = false
            }
        }
        
        if allCharacteristicsDiscovered {
            for characteristic:CBCharacteristic in service.characteristics!{
                if(D){print("\(characteristic.uuid.uuidString)")}
            }
            
            sensorTagDelegate?.Ready()
            ready = true
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) { /** We only listen to characteristics **/ }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if(D){print("PeripheralDiscoverer: didUpdateValueForCharacteristic")}
        
        if(error == nil){
            if characteristic.uuid == SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_ACCELEROMETER_DATA {
                latestAcell = controller.getAccelerometerData(value: characteristic.value! as NSData )
                sensorTagDelegate?.Accelerometer(measurement: latestAcell!)
            }
            if characteristic.uuid == SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_MAGNETOMETER_DATA {
                latestMagneto = controller.getMagnetometerData(value: characteristic.value! as NSData )
                sensorTagDelegate?.Magnetometer(measurement: latestMagneto!)
            }
            if characteristic.uuid == SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_GYROSCOPE_DATA {
                latestGyro = controller.getGyroscopeData(value: characteristic.value! as NSData )
                sensorTagDelegate?.Gyroscope(measurement: latestGyro!)
            }
            if(readyForCalibration()){
                sensorTagDelegate?.ReadyForCalibration()
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if(D){print("PeripheralDiscoverer: didUpdateNotificationStateForCharacteristic charac=\(characteristic.uuid.uuidString) isNotifying=\(characteristic.isNotifying)")}
    }
}

extension SensorTagPeripheral {
    private func validService(uuid : CBUUID) -> Bool{
        return SENSORTAG_SERVICES.array.contains(uuid)
    }
    
    private func validCharacteristic(uuid : CBUUID) -> Bool {
        return SENSORTAG_CHARACTERISTICS.array.contains(uuid)
    }
}
