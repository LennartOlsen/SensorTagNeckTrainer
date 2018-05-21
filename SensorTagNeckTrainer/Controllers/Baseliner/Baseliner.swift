//
//  Baseliner.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 16/03/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

class Baseliner {
    private let measurementMax = 3
    private let measurementTime = 1
    private let measurementPause = 5
    
    private let queueLabel : String
    
    private let D = true
    private var magnetometerCollectionRate = 0
    
    private var delegate : BaselinerDelegate!
    private var device : SensorTagPeripheral
    private var measurements = [Measurement]()
    private var baselines = [Baseline]()
    private var timer: DispatchSourceTimer?
    private let queue: DispatchQueue
    
    private var measurementIdxCount = 0
    
    private var collectionType = DataEntryTypes.allReversible[0]
    private var baseline : Baseline
    
    private var stopped = false
    private var isCollecting = false
    
    init(device : SensorTagPeripheral, delegate : BaselinerDelegate){
        self.device = device
        self.delegate = delegate
        self.baseline = Baseline(type : collectionType)
        queueLabel = "net.lennartolsen." + "Baseliner" + ".collection"
        queue = DispatchQueue(label : self.queueLabel)
        device.attach(observer: self)
    }
    
    private func addMeasurement(_ measurement : Measurement){
        self.measurements.append(measurement)
        self.baseline.addValues(x: measurement.x, y: measurement.y, z: measurement.z)
    }
    
    func getBaseline() -> Baseline {
        return baseline
    }
    
    func start() {
        self.pause()
    }
    
    private func pause() {
        if(stopped){return}
        print("Called pause baseliner")
        self.pauseCounter()
            queue.asyncAfter(deadline: .now() + .seconds(self.measurementPause), execute : {
                self.stopPauseCounter()
                self.startCollection()
            })
    }
    
    private func startCollection(){
        if(stopped){return}
        self.delegate.Start(type: self.collectionType, time: self.measurementTime)
        self.isCollecting = true
        queue.asyncAfter(deadline: .now() + .seconds(self.measurementTime), execute : {
            print("started new async on \(self.queue.label)")
            self.isCollecting = false
            self.measurementIdxCount += 1
            if(self.measurementIdxCount >= self.measurementMax){
                self.delegate.End(result: self.baseline)
                self.collectionType = DataEntryTypes.getNextReversible(dataEntry: self.baseline.type)
                self.baselines.append(self.baseline)
                self.baseline = Baseline(type : self.collectionType)
                self.measurementIdxCount = 0
                if(self.collectionType == DataEntryTypes.allReversible[0]){
                    /** Done **/
                    self.delegate.Completed(result: self.baselines)
                }
            }
            self.pause()
        })
    }
    
    private func pauseCounter(){
        print("Called pause counter")
        var tMinus = self.measurementPause
        
        let mainQueue = DispatchQueue.main
        timer = DispatchSource.makeTimerSource(queue: mainQueue)
        timer!.schedule(deadline: .now(), repeating: .seconds(1))
        timer!.setEventHandler { [weak self] in
            self?.delegate.Next(type: (self?.collectionType)!, time: tMinus)
            if (self?.D)! {
                print("Magnetometer Rate \(self?.magnetometerCollectionRate) hz")
                self?.magnetometerCollectionRate = 0
            }
            tMinus -= 1
        }
        timer!.resume()
    }
    private func stopPauseCounter(){
        timer?.cancel()
        timer = nil
    }
    
    func stop() {
        stopped = true
        timer?.cancel()
        timer = nil
        
    }
    
    // make sure that collection is always stopped
    deinit {
        print("Baseliner deinit")
        stop()
        device.remove(observer: self)
    }
}

extension Baseliner : SensorTagDelegate {
    
    
    func Magnetometer(measurement: MagnetometerMeasurement, uuid : UUID) {
        if(isCollecting){
            self.addMeasurement(measurement)
        }
        if(D){
            self.magnetometerCollectionRate += 1
        }
    }
    
    var id : String {
        get {
            return "Baseliner"
        }
    }
    
    func Ready(uuid : UUID) {}
    
    func Errored(uuid : UUID) {}
    
    func Accelerometer(measurement: AccelerometerMeasurement, uuid : UUID) {}
    
    func Gyroscope(measurement: GyroscopeMeasurement, uuid : UUID) {}
    
    func ReadyForCalibration(uuid : UUID) {}
    
    func Calibrated(values: [[Double]], uuid : UUID) {}
}
