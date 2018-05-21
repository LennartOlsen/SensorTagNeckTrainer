//
//  Predictor.swift
//  SensorTagRaiderMacOS
//
//  Created by Lennart Olsen on 19/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation
import CoreML

class Predictor {
    
    struct ModelConstants {
        static let numOfFeatures = 6
        static let predictionWindowSize = 10
        static let hiddenInLength = 200
        static let hiddenCellInLength = 200
    }
    
    var predictionWindowDataArray : MLMultiArray?
    var lastHiddenCellOutput: MLMultiArray?
    var lastHiddenOutput: MLMultiArray?
    
    let activityClassificationModel = activityClassifier()
    
    init(){
        predictionWindowDataArray = try? MLMultiArray(shape : [1,ModelConstants.predictionWindowSize,ModelConstants.numOfFeatures] as [NSNumber], dataType : MLMultiArrayDataType.double)
        lastHiddenOutput = try? MLMultiArray(shape:[ModelConstants.hiddenInLength as NSNumber], dataType: MLMultiArrayDataType.double)
        lastHiddenCellOutput = try? MLMultiArray(shape:[ModelConstants.hiddenCellInLength as NSNumber], dataType: MLMultiArrayDataType.double)
    }
    
    func PerformPrediction(dataEntry : DataEntry) -> activityClassifierOutput? {
        guard let dataArray = predictionWindowDataArray else { return nil }
        for (i, collection) in dataEntry.collections.enumerated() {
            for measurement in collection.measurements {
                if measurement is MagnetometerMeasurement {
                    dataArray[[0 , i , 0] as [NSNumber]] = measurement.x as NSNumber
                    dataArray[[0 , i , 1] as [NSNumber]] = measurement.y as NSNumber
                    dataArray[[0 , i , 2] as [NSNumber]] = measurement.z as NSNumber
                }
                if measurement is GyroscopeMeasurement {
                    dataArray[[0 , i , 3] as [NSNumber]] = measurement.x as NSNumber
                    dataArray[[0 , i , 4] as [NSNumber]] = measurement.y as NSNumber
                    dataArray[[0 , i , 5] as [NSNumber]] = measurement.z as NSNumber
                }
            }
        }
        
        let prediction : activityClassifierOutput?
        do {
            prediction = try
                activityClassificationModel.prediction(features: dataArray,
                                                        hiddenIn: lastHiddenOutput,
                                                        cellIn: lastHiddenCellOutput)
        } catch {
            print("Unexpected Error : \(error)")
            return nil
        }
        lastHiddenOutput = prediction?.hiddenOut
        lastHiddenCellOutput = prediction?.cellOut
        return prediction
    }
}
