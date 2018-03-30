//
//  LocalRepository.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 23/03/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

class LocalRepository {
    let file : String
    let dir : URL?
    let locationURL : URL?
    
    private let D = true
    
    init(file : String = "output.txt"){
        /** Establish 'Connection' **/
        self.file = file
        self.dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        self.locationURL = dir!.appendingPathComponent(file)
        
        if(D){print("Opened connection to \(locationURL)")}
    }
    
    func put(data : String){
        do {
            if let url = locationURL{
                try data.write(to: url, atomically: false, encoding: .utf8)
            }
        }
        catch {
            print("WARNING : Could not write to file \(locationURL) \(error)")
        }
    }
    
    func get() -> String{
        do {
            if let url = locationURL{
                return try String(contentsOf: url, encoding: .utf8)
            }
        }
        catch {
            print("WARNING : Could not read from file \(locationURL) \(error)")
        }
        return ""
    }
}
