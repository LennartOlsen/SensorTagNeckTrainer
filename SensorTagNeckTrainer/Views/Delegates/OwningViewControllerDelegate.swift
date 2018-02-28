//
//  OwningViewControllerDelegate.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 27/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation
import Cocoa

protocol OwningViewControllerDelegate {
    func willDestroy(sender : NSViewController)
}

