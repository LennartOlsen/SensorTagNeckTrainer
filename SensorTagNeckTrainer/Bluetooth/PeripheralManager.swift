//
//  PeripheralDiscoverer.swift
//  SensorTagRaider
//
//  Created by Lennart Olsen on 13/01/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation
import CoreBluetooth


class PeripheralManager : NSObject {
    
    private var D = false
    
    
    //Singleton pattern, we want only one instance of this class.
    static let sharedInstance = PeripheralManager()
    
    var central:CBCentralManager?
    
    var listenerDelegate: BluetoothListenerDelegate?
    
    var discoveredDevices:[UUID:CBPeripheral] = [:]
    
    private override init()
    {
        super.init()
        self.central = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        if(D){print("PeripheralDiscoverer.init()")}
    }
    
    func connectToDevice(uuid : UUID) -> CBPeripheral! {
        print("Connecting to device!", uuid, discoveredDevices[uuid])
        if let device = discoveredDevices[uuid] {
            self.central?.connect(device, options: nil)
            return device
        }
        return nil
    }
    
    func stopScan(){
        central?.stopScan()
    }
}

extension PeripheralManager : CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if (central.state == CBManagerState.poweredOn) {
            if(D){print("PeripheralDiscoverer: didUpdateState ON")}
            
            //All serivces
            self.central?.scanForPeripherals(withServices:nil, options: nil)
        } else {
            // do something like alert the user that ble is not on
            if(D){print("PeripheralDiscoverer: didUpdateState \(central.state.rawValue)")}
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let id = peripheral.identifier //iOS abstraction over hardware address to comply with privacy of the MAC address.
        
        //Add peripheral to dict.
        self.discoveredDevices[id] = peripheral
        
        if(D){print("PeripheralDiscoverer: didDiscoverPeripheral: \(id.uuidString) \(String(describing: peripheral.name))")}
        
    
        listenerDelegate?.didDiscover(peripheralDevice: peripheral)
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if(D){print("PeripheralDiscoverer \(peripheral.name!): didConnectPeripheral: \(peripheral.state.rawValue)")}
        
        
        listenerDelegate?.didConnect(peripheralDevice: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if(D){print("PeripheralDiscoverer \(peripheral.name!): didDisconnectPeripheral: \(peripheral.state.rawValue)")}
    }
}
