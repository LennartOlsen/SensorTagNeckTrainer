//
//  ObserverPattern.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 16/03/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

class ObserverPattern : NSObject {
    var observers = [ObserverProtocol]()
    
    func attach(observer : ObserverProtocol){
        observers.append(observer)
    }
    
    func remove(observer : ObserverProtocol) {
        observers = observers.filter{ $0.id != observer.id }
        print("Removed observer, \(observer.id)")
    }
}
