//
//  PerformanceControllerDelegate.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 17/04/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

protocol PerformanceControllerDelegate {
    func updatedMetric(result : PerformanceMetric, startTime : Int)
    func endedCollection(results : [PerformanceMetric], totalTime : Int)
}
