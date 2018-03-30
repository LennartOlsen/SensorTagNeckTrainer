//
//  BaselinerDelegate.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 19/03/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

protocol BaselinerDelegate {
    /** I do "string" exercise in "Double" ms **/
    func Next(type : DataEntryTypes, time : Int)
    
    /** I started "string" exercise for "Double" ms **/
    func Start(type : DataEntryTypes, time : Int)
    
    /** I ended "string" excersise **/
    func End(result : Baseline)
    
    /** I recorded all "result" exercises **/
    func Completed(result : [Baseline])
}
