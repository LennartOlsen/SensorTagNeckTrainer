//
//  RecorderController.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 27/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Cocoa
import CoreBluetooth
import Charts

class RecorderController: NSViewController {
    
    private var baseliner : Baseliner!
    private var magnetometerDevice : SensorTagPeripheral!
    
    private var player : SoundPlayer!
    
    private var baselines = [Baseline]()
    
    private var baselineComparator : BaselineComparator!
    
    @IBOutlet weak var settingsButton: NSButton!
    @IBOutlet weak var baselineButton: NSButton!
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var accelerometerController: ObserverController!
    @IBOutlet weak var magnetometerController: ObserverController!
    @IBOutlet weak var gyroscopeController: ObserverController!
    
    @IBAction func doSettings(_ sender: NSButton) {
        for(_, device) in devices! {
            device.calibrate()
        }
    }
    @IBAction func doBaseline(_ sender: Any) {
        performSegue(withIdentifier:
            NSStoryboardSegue.Identifier(rawValue: "BaselineControllerSegue"),
                     sender: self)
    }
    
    var devices : [UUID : SensorTagPeripheral]? = nil {
        didSet {
            ready()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player = SoundPlayer()
        settingsButton.isEnabled = false
        baselineButton.isEnabled = false
        infoLabel.textColor = Colors.Text
        infoLabel.font = Fonts.DisplayOne
        accelerometerController.setUpLineChart()
        magnetometerController.setUpLineChart()
        gyroscopeController.setUpLineChart()
    }
    
    override func viewDidAppear() {
        if devices == nil {
            performSegue(withIdentifier:
                NSStoryboardSegue.Identifier(rawValue: "ConnectControllerSegue"),
                         sender: self)
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let vc = segue.destinationController as? ConnectController {
            vc.owningDelegate = self
        }
        if let vc = segue.destinationController as? BaselineController {
            vc.device = magnetometerDevice
            vc.owningDelegate = self
        }
    }
    
    func ready(){
        infoLabel.stringValue = "Connected to sensors, setting up"
        for (_, device) in devices! {
            device.attach(observer : self)
            device.setup()
            if let n = device.getPeripheralName() {
                infoLabel.stringValue += ", \(n)"
            }
        }
    }
}

extension RecorderController : OwningViewControllerDelegate {
    func willDestroy(sender: NSViewController) {
        if let s = sender as? ConnectController {
            self.devices = s.sensorTags
        }
        if let s = sender as? BaselineController {
            print("retuned from baseliner", s.baselines)
            self.baselines = s.baselines
            self.baselineComparator = BaselineComparator(baselines: s.baselines, device: self.magnetometerDevice)
            self.baselineComparator.attach(observer: self)
        }
    }
    
}

extension RecorderController : SensorTagDelegate {
    func Ready() {
        //infoLabel.stringValue = "Connected to headset, done setting up"
        
        var i = 0
        for (_, device) in devices! {
            if(i == 0){
                device.listenForMagnetometer()
                self.magnetometerDevice = device
            }
            if(i == 1){
                //device.listenForAccelerometer()
                device.listenForGyroscope()
            }
            i += 1
        }
    }
    
    func Errored() {
    }
    
    func Accelerometer(measurement: AccelerometerMeasurement) {
        accelerometerController.addData(name: "Accelerometer", measurement: measurement)
    }
    
    func Magnetometer(measurement: MagnetometerMeasurement) {
        magnetometerController.addData(name: "Magnetometer", measurement: measurement)
    }
    
    func Gyroscope(measurement: GyroscopeMeasurement) {
        gyroscopeController.addData(name: "Gyroscope", measurement: measurement)
    }
    
    func ReadyForCalibration() {
        /** This is called many many times **/
        if(!settingsButton.isEnabled){
            player.play(resource : .intro)
            settingsButton.isEnabled = true
        }
    }
    
    func Calibrated(values: [[Double]]) {
        baselineButton.isEnabled = true
    }
}

extension RecorderController : BaselineComparatorDelegate {
    func gotType(_ type: DataEntryTypes) {
        print("Got result from baseline comparator : \(type.rawValue)")
    }
}

extension RecorderController : ObserverProtocol {
    var id: String { get { return "recorderController"} }
}
