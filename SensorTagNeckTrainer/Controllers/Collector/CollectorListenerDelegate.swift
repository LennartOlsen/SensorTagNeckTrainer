//
//  CollectionListenerDelegate.swift
//  SensorTagRaiderMacOS
//
//  Created by Lennart Olsen on 12/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

protocol CollectorListenerDelegate {
    func collectionIsFinished(dataEntry : DataEntry)
}
