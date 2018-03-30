//
//  SDUPeripheral.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 12/03/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation
import CoreBluetooth

let SDU_DEVICE_NAMES = [
    "BC05C954BBC78791"
]

class SDUPeripheral : NSObject {
    private let peripheral : CBPeripheral
    
    private var enablyBytes : NSData
    private var enableValue = 1
    
    private let D = true
    
    private var ready = false
    
    private var services = [String : CBService]()
    private var characteristics = [String: CBCharacteristic]()
    
    let controller = Controller()
    
    init(peripheral : CBPeripheral){
        self.peripheral = peripheral
        self.enablyBytes = NSData(bytes: &enableValue, length: MemoryLayout<UInt8>.size)
        super.init()
        self.peripheral.delegate = self
    }
    
    static func validate(device : CBPeripheral) -> Bool {
        if let n = device.name {
            return SDU_DEVICE_NAMES.contains(n)
        }
        return false
    }
    
    
    func setup(){
        peripheral.discoverServices(SDU_SERVICES.array)
        print(peripheral.state.rawValue, peripheral.name!)
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
}

extension SDUPeripheral {
    func listenForAccelerometerAndGyro() {
        if self.services[SDU_SERVICES.SDU_ACCELEROMETER_SERVICE.uuidString] != nil {
            
            if let configCharacteristic = self.characteristics[SDU_CHARACTERISTICS.SDU_ACCELEROMETER_CONFIG.uuidString] {
                peripheral.setNotifyValue(true, for: configCharacteristic)
            }
        }
    }
}

extension SDUPeripheral : CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if(D){print("Did discover services")}
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
                !SDU_SERVICES.NO_CHARACTERISTICS_ARRAY.contains(service.uuid) {
                allCharacteristicsDiscovered = false
            }
        }
        
        if allCharacteristicsDiscovered {
            for characteristic:CBCharacteristic in service.characteristics!{
                if(D){print("\(characteristic.uuid.uuidString)")}
            }
            
            //sensorTagDelegate?.Ready()
            ready = true
            
            /** Do not this **/
            self.listenForAccelerometerAndGyro()
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if(D){print("PeripheralDiscoverer: didUpdateValueForCharacteristic")}
        
        if(error == nil){
            if characteristic.uuid == SDU_CHARACTERISTICS.SDU_ACCELEROMETER_CONFIG {
                let (accel, gyro) = controller.getAccelerometerAndGyroscopeData(value: characteristic.value! as NSData )
                print("Got accel \(accel.x), and gyro \(gyro.x)")
                //sensorTagDelegate?.Accelerometer(measurement: latestAcell!)
            }
        }
    }
}

extension SDUPeripheral {
    private func validService(uuid : CBUUID) -> Bool{
        return SDU_SERVICES.array.contains(uuid)
    }
    
    private func validCharacteristic(uuid : CBUUID) -> Bool {
        return SDU_CHARACTERISTICS.array.contains(uuid)
    }
}
