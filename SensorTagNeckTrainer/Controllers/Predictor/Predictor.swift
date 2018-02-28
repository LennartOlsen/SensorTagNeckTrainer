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
        static let numOfFeatures = 9
        static let predictionWindowSize = 4
        static let sensorsUpdateInterval = 1.0 / 4.0
        static let hiddenInLength = 200
        static let hiddenCellInLength = 200
    }
    
    var predictionWindowDataArray : MLMultiArray?
    var lastHiddenCellOutput: MLMultiArray?
    var lastHiddenOutput: MLMultiArray?
    
    let activityClassificationModel = timeFramedActivityClassifier()
    
    init(){
        predictionWindowDataArray = try? MLMultiArray(shape : [1,ModelConstants.predictionWindowSize,ModelConstants.numOfFeatures] as [NSNumber], dataType : MLMultiArrayDataType.double)
        lastHiddenOutput = try? MLMultiArray(shape:[ModelConstants.hiddenInLength as NSNumber], dataType: MLMultiArrayDataType.double)
        lastHiddenCellOutput = try? MLMultiArray(shape:[ModelConstants.hiddenCellInLength as NSNumber], dataType: MLMultiArrayDataType.double)
    }
    
    func PerformPrediction(dataEntry : DataEntry) -> String? {
        // Add the current accelerometer reading to the data array
        guard let dataArray = predictionWindowDataArray else { return "Error" }
        for (i, collection) in dataEntry.collections.enumerated() {
            for measurement in collection.measurements {
                if measurement is AccelerometerMeasurement {
                    dataArray[[0 , i , 0] as [NSNumber]] = measurement.x as NSNumber
                    dataArray[[0 , i , 1] as [NSNumber]] = measurement.y as NSNumber
                    dataArray[[0 , i , 2] as [NSNumber]] = measurement.z as NSNumber
                }
                if measurement is MagnetometerMeasurement {
                    dataArray[[0 , i , 3] as [NSNumber]] = measurement.x as NSNumber
                    dataArray[[0 , i , 4] as [NSNumber]] = measurement.y as NSNumber
                    dataArray[[0 , i , 5] as [NSNumber]] = measurement.z as NSNumber
                }
                if measurement is GyroscopeMeasurement {
                    dataArray[[0 , i , 6] as [NSNumber]] = measurement.x as NSNumber
                    dataArray[[0 , i , 7] as [NSNumber]] = measurement.y as NSNumber
                    dataArray[[0 , i , 8] as [NSNumber]] = measurement.z as NSNumber
                }
            }
        }
        
        
       guard let prediction = try? activityClassificationModel.prediction(features: dataArray,
                                                                          hiddenIn: lastHiddenOutput,
                                                                          cellIn: lastHiddenCellOutput) else {
                                                                            print("Fatalus")
                                                                            return "N/A"
        }
        
        // Update the state vectors
        lastHiddenOutput = prediction.hiddenOut
        lastHiddenCellOutput = prediction.cellOut
        
        // Return the predicted activity - the activity with the highest probability
        print("predicted \(String(describing: prediction.type)) from \(dataEntry.type), with prop \(String(describing: prediction.typeProbability)),")
        
        return prediction.type
    }
}
