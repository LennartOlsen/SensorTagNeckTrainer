//
//  RecorderController.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 27/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Cocoa
import CoreBluetooth

class RecorderController: NSViewController {
    
    @IBOutlet weak var settingsButton: NSButton!
    @IBOutlet weak var infoLabel: NSTextField!
    @IBAction func doSettings(_ sender: NSButton) {
        device?.calibrate()
    }
    
    var device : SensorTagPeripheral? = nil {
        didSet {
            ready()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsButton.isEnabled = false
    }
    
    override func viewDidAppear() {
        if device == nil {
            performSegue(withIdentifier:
                NSStoryboardSegue.Identifier(rawValue: "ConnectControllerSegue"),
                         sender: self)
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let vc = segue.destinationController as? ConnectController {
            vc.owningDelegate = self
        }
    }
    
    func ready(){
        device?.sensorTagDelegate = self
        device?.setup()
        infoLabel.stringValue = "Connected to headset, setting up"
    }
}

extension RecorderController : OwningViewControllerDelegate {
    func willDestroy(sender: NSViewController) {
        if let s = sender as? ConnectController {
            self.device = s.sensorTag
        }
    }
    
}

extension RecorderController : SensorTagDelegate {
    func Ready() {
        infoLabel.stringValue = "Connected to headset, done setting up"
        device?.listenForGyroscope()
        device?.listenForMagnetometer()
        device?.listenForAccelerometer()
    }
    
    func Errored() {
    }
    
    func Accelerometer(measurement: AccelerometerMeasurement) {
        print("got accel")
    }
    
    func Magnetometer(measurement: MagnetometerMeasurement) {
        print("got maget")
    }
    
    func Gyroscope(measurement: GyroscopeMeasurement) {
        print("got gyro")
    }
    
    func ReadyForCalibration() {
        settingsButton.isEnabled = true
    }
    
    func Calibrated(values: [[Double]]) {
    }
    
    
}
