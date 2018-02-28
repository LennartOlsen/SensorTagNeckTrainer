//
//  BluetoothManagerDelegate.swift
//  SensorTagRaider
//
//  Created by Lennart Olsen on 13/01/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BluetoothListenerDelegate {
    
    /** When  discovering One new device **/
    func didDiscover(peripheralDevice : CBPeripheral)
    
    func didConnect(peripheralDevice : CBPeripheral)
}
