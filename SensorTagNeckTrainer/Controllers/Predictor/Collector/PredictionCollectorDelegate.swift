//
//  PredictionCollectorDelegate.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 01/04/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

protocol PredictionCollectorDelegate : ObserverProtocol {
    func prediction( output : activityClassifierOutput )
}
