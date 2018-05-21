//
//  PerformanceMetric.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 17/04/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

class PerformanceMetric {
    let Typ : DataEntryTypes.RawValue
    // totalTime in seconds
    var totalTime : Int = 0
    private var time : Int = 0
    private var collectiveProbaility : Double = 0.0
    private var readings : Int = 0
    
    init(type : DataEntryTypes.RawValue){
        Typ = type
    }
    
    func addMetric(time : Int, probability : Double){
        totalTime += time
        self.time = time
        readings += 1
        collectiveProbaility = (collectiveProbaility + probability) / 2
    }
}
