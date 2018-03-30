//
//  BaselineComparatorDelegate.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 26/03/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

protocol BaselineComparatorDelegate : ObserverProtocol {
    func gotType(_ type : DataEntryTypes)
}
