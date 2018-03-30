//
//  BaseBluetoothPeripheral.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 16/03/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation
import CoreBluetooth

class BaseBluetoothPeripheral : ObserverPattern {
    
    let peripheral : CBPeripheral
    
    var services = [String : CBService]()
    var characteristics = [String: CBCharacteristic]()
    
    private let validCharacteristics : [CBUUID]
    private let validServices : [CBUUID]
    private let noCharacteristServices : [CBUUID]
    
    private var enableValue = 1
    var enablyBytes : NSData
    
    init(peripheral : CBPeripheral,
         validCharacteristics : [CBUUID],
         validServices : [CBUUID], 
         noCharacteristServices : [CBUUID]){
        self.peripheral = peripheral
        self.validCharacteristics = validCharacteristics
        self.validServices = validServices
        self.noCharacteristServices = noCharacteristServices
        self.enablyBytes = NSData(bytes: &enableValue, length: MemoryLayout<UInt8>.size)
        super.init()
    }
    
    func setup(){
        peripheral.discoverServices(nil)
    }
    
    func getPeripheralName() -> String? {
        return peripheral.name
    }
    
    func observers() -> [SensorTagDelegate] {
        return super.observers as! [SensorTagDelegate]
    }
}

extension BaseBluetoothPeripheral {
    private func validService(uuid : CBUUID) -> Bool{
        return validServices.contains(uuid)
    }
    
    private func validCharacteristic(uuid : CBUUID) -> Bool {
        return validCharacteristics.contains(uuid)
    }
    
    private func addCharateristic(_ characteristic : CBCharacteristic) -> Bool {
        if(validCharacteristic(uuid : characteristic.uuid)){
            characteristics[characteristic.uuid.uuidString] = characteristic
            return true
        }
        return false
    }
    
    private func addService(_ service : CBService) -> Bool {
        if(validService(uuid : service.uuid)){
            services[service.uuid.uuidString] = service
            return true
        }
        return false
    }
}

extension BaseBluetoothPeripheral { /** CBPeripheralDelegateHelepers **/
    func handleDidDiscoverService(peripheral: CBPeripheral) {
        for service:CBService in peripheral.services!{
            if(addService(service)){
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func handleDidDiscoverCharacteristic(peripheral : CBPeripheral, service : CBService) -> Bool {
        
        for c:CBCharacteristic in service.characteristics!{
            _ = addCharateristic(c)
        }
        
        //Determine if charasteristics for all services has been discovered
        var allCharacteristicsDiscovered = true
        for service:CBService in peripheral.services!{
            if service.characteristics == nil && !noCharacteristServices.contains(service.uuid) {
                allCharacteristicsDiscovered = false
            }
        }
        return allCharacteristicsDiscovered
    }
}
