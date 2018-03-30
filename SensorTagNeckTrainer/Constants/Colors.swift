//
//  Colors.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 02/03/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation
import QuartzCore
import Cocoa

struct Colors {
    static let Background = NSColor(cgColor: CGColor(red: 172.0/255.0,
                                                     green: 181.0/255.0,
                                                     blue: 181.0/255.0,
                                                     alpha: 1.0))
    
    static let Text = NSColor(cgColor: CGColor(red: 48.0/255.0,
                                               green: 40.0/255.0,
                                               blue: 34.0/255.0,
                                               alpha: 1.0))
    
    static let GraphCircle = NSColor(cgColor: CGColor(red: 48.0/255.0,
                                                      green: 40.0/255.0,
                                                      blue: 34.0/255.0,
                                                      alpha: 1.0))
    
    static let GraphLine = NSColor(cgColor: CGColor(red: 48.0/255.0,
                                                    green: 40.0/255.0,
                                                    blue: 34.0/255.0,
                                                    alpha: 1.0))
    
    static let Transparent = NSColor(cgColor: CGColor(red: 1/255.0,
                                                     green: 1/255.0,
                                                     blue: 1/255.0,
                                                     alpha: 0.0))
    
    static let Darken = NSColor(cgColor: CGColor(red: 1/255.0,
                                                      green: 1/255.0,
                                                      blue: 1/255.0,
                                                      alpha: 0.05))
    
    /**168, 139, 127**/
    static let GraphXLine = NSColor(cgColor: CGColor(red: 1/255.0,
                                                    green: 1/255.0,
                                                    blue: 127.0/255.0,
                                                    alpha: 0.95))
    /**169, 158, 147**/
    static let GraphYLine = NSColor(cgColor: CGColor(red: 1/255.0,
                                                     green: 158.0/255.0,
                                                     blue: 1/255.0,
                                                     alpha: 0.95))
    
    /**174, 166, 164**/
    static let GraphZLine = NSColor(cgColor: CGColor(red: 174.0/255.0,
                                                     green: 1/255.0,
                                                     blue: 1/255.0,
                                                     alpha: 0.95))
}
