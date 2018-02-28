//
//  DataEntry.swift
//  SensorTagRaiderMacOS
//
//  Created by Lennart Olsen on 12/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

enum DataEntryTypes : String {
    case tiltLeft = "tilt_left"
    case tiltLeftBack = "tilt_left_back"
    case tiltRight = "tilt_right"
    case tiltRightBack = "tilt_right_back"
    
    case rotateLeft = "rotate_left"
    case rotateLeftBack = "rotate_left_back"
    case rotateRight = "rotate_right"
    case rotateRightBack = "rotate_right_back"
    
    case bendForward = "bend_forward"
    case bendForwardBack = "bend_forward_back"
    case bendBackward = "bend_backward"
    case bendBackwardBack = "bend_backward_back"
    
    case hunchForward = "hunch_forward"
    case hunchForwardBack = "hunch_forward_back"
    
    case neutral = "neutral" /** Special Case has no reversible **/
    
    static let allReversible = [tiltLeft, tiltRight, rotateLeft, rotateRight, bendForward, bendBackward, hunchForward,neutral]
    static let allBacks = [tiltLeftBack, tiltRightBack, rotateLeftBack, rotateRightBack, bendForwardBack, bendBackwardBack, hunchForwardBack,neutral]
    
    static func getNext(dataEntry : DataEntryTypes) -> DataEntryTypes {
        if let i = allReversible.index(of: dataEntry)  {
            return allBacks[i]
        } else if let i = allBacks.index(of: dataEntry) {
            return allReversible[i]
        }
        
        return .tiltLeft
    }
}

class DataEntry {
    
    let type : DataEntryTypes
    
    var collections : [MeasurementCollection] = []
    
    let collectionId : String
    
    init(type : DataEntryTypes, id : String){
        self.type = type
        self.collectionId = id
    }
}

extension DataEntry {
    func addMeasurement(accelerometer : AccelerometerMeasurement, magnetometer : MagnetometerMeasurement, gyroscope : GyroscopeMeasurement){
        collections.append(MeasurementCollection(accelerometer: accelerometer, magnetometer: magnetometer, gyroscope: gyroscope))
    }
}
