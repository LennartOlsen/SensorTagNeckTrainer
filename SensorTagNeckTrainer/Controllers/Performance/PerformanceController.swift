//
//  PerformanceController.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 17/04/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

class PerformanceController {
    let predictionCollector : PredictionCollector
    let delegate : PerformanceControllerDelegate
    private var predictionCutoff : Double = 0.0
    private var isCollecting : Bool = false
    private var collection : [String : PerformanceMetric] = [String : PerformanceMetric]()
    private var lastPrediction : activityClassifierOutput?
    private var lastReading : String?
    private var lastTime : Int?
    private var startTime : Int = 0
    
    
    init(predictionCollector : PredictionCollector, delegate : PerformanceControllerDelegate){
        self.predictionCollector = predictionCollector
        self.delegate = delegate
        
        self.predictionCollector.attach(observer: self)
    }
    
    func setCutoff(_ cutoff : Double) {
        self.predictionCutoff = cutoff
    }
    
    func startPerformanceCollection() {
        self.predictionCollector.startPrediction()
        isCollecting = true
        startTime = Int(Date().timeIntervalSince1970)
    }
    
    func stopPerformanceCollection() {
        isCollecting = false
        delegate.endedCollection(results: Array(collection.values), totalTime: Int(Date().timeIntervalSince1970) - startTime)
    }
    
    func updateCollection(_ with : activityClassifierOutput){
        var type = with.type
        if collection[type] == nil {
            collection[type] = PerformanceMetric(type : type)
        }
        if collection[DataEntryTypes.neutral.rawValue] == nil {
            collection[DataEntryTypes.neutral.rawValue] = PerformanceMetric(type : DataEntryTypes.neutral.rawValue)
        }
        if lastTime == nil {
            lastTime = Int(Date().timeIntervalSince1970)
        }
        if let prop = with.typeProbability[type]{
            let time = Int(Date().timeIntervalSince1970) - lastTime!
            if prop < predictionCutoff {
                type = DataEntryTypes.neutral.rawValue
            }
            collection[type]?.addMetric(time: time, probability: prop)
            delegate.updatedMetric(result: collection[type]!, startTime: startTime)
            lastTime = Int(Date().timeIntervalSince1970)
        }
        
    }
}

extension PerformanceController : PredictionCollectorDelegate {
    func prediction(output: activityClassifierOutput) {
        self.lastPrediction = output
        if(self.isCollecting){
            updateCollection(output)
        }
    }
    
    var id: String {
        get {
            return "PerformanceController"
        }
    }
}
