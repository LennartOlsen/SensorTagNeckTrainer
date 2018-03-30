//
//  Constants.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 12/03/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation
import CoreBluetooth

struct SDU_SERVICES {
    static let DeviceInformation                                    = CBUUID(string: "180A")
    static let SDU_ACCELEROMETER_SERVICE                            = CBUUID(string : "A2C70010-8F31-11E3-B148-0002A5D5C51B")
    
    static let array : [CBUUID] = [
        SDU_SERVICES.DeviceInformation,
        SDU_SERVICES.SDU_ACCELEROMETER_SERVICE,
    ]
    
    static let NO_CHARACTERISTICS_ARRAY : [CBUUID] = [
        SDU_SERVICES.DeviceInformation,
    ]
}

struct SDU_CHARACTERISTICS {
    static let SDU_ACCELEROMETER_CONFIG                               = CBUUID(string : "A2C70031-8F31-11E3-B148-0002A5D5C51B")
    
    static let array : [CBUUID] = [
        SDU_CHARACTERISTICS.SDU_ACCELEROMETER_CONFIG,
    ]
}
