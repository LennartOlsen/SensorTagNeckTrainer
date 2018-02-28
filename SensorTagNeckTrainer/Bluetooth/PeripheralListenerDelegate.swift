//
//  PeripheralListenerDelegate.swift
//  SensorTagRaider
//
//  Created by Lennart Olsen on 03/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol PeripheralListenerDelegate {
    
    func didDiscoverService(service : CBService)
    
    func didDiscoverCharacteristic(characteristic : CBCharacteristic, service : CBService?)
    
    func didDiscoverDescriptor(descriptor : CBDescriptor, charecteristic : CBCharacteristic?)
    
    func didReceviceUpdateFromCharecteristic(charecteristic : CBCharacteristic)
    
    func didReceviceUpdateFromDescriptor(descriptor : CBDescriptor)
}
