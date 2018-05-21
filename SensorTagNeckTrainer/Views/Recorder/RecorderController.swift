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
    @IBOutlet weak var dataCollectorButton: NSButton!
    @IBOutlet weak var predictionResults: NSTextField!
    
    private var predictionCollector : PredictionCollector!
    
    @IBAction func doSettings(_ sender: NSButton) {
        for(_, device) in devices! {
            device.calibrate()
        }
        if (predictionCollector != nil) {
            performSegue(withIdentifier:
                NSStoryboardSegue.Identifier(rawValue: "PredictionViewControllerSegue"),
                         sender: self)
        }
    }
    @IBAction func doBaseline(_ sender: Any) {
        performSegue(withIdentifier:
            NSStoryboardSegue.Identifier(rawValue: "BaselineControllerSegue"),
                     sender: self)
    }
    @IBAction func doDataCollection(_ sender: Any) {
        performSegue(withIdentifier:
            NSStoryboardSegue.Identifier(rawValue: "DataCollectorControllerSegue"),
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
        dataCollectorButton.isEnabled = false
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
        if let vc = segue.destinationController as? DataCollector {
            vc.devices = self.devices
        }
        if let vc = segue.destinationController as? PredictionViewController {
            vc.predictionCollector = self.predictionCollector
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
        print("Prediction controller setup")
        predictionCollector = PredictionCollector(devices: self.devices!)
    }
}

extension RecorderController : OwningViewControllerDelegate {
    func willDestroy(sender: NSViewController) {
        if let s = sender as? ConnectController {
            self.devices = s.sensorTags
        }
        if let s = sender as? BaselineController {
            self.baselines = s.baselines
            self.baselineComparator = BaselineComparator(baselines: s.baselines, device: self.magnetometerDevice)
            self.baselineComparator.attach(observer: self)
        }
    }
    
}

extension RecorderController : SensorTagDelegate {
    
    func Ready(uuid : UUID) {
        //infoLabel.stringValue = "Connected to headset, done setting up"
        
        var i = 0
        for (uuid, device) in devices! {
            if(uuid.uuidString == "4B6F1795-4070-4445-BCB8-2941DA78A8FA"){ /** Magnet **/
                device.listenForMagnetometer()
                self.magnetometerDevice = device
            }
            if(uuid.uuidString == "A5CD97DB-8390-4122-B01C-7F5A54870F97"){ /** Gyro **/
                device.listenForGyroscope()
            }
            i += 1
        }
    }
    
    func Errored(uuid: UUID) {}
    
    func Accelerometer(measurement: AccelerometerMeasurement, uuid : UUID) {
        accelerometerController.addData(name: "Accelerometer", measurement: measurement)
    }
    
    func Magnetometer(measurement: MagnetometerMeasurement, uuid : UUID)  {
        magnetometerController.addData(name: "Magnetometer", measurement: measurement)
    }
    
    func Gyroscope(measurement: GyroscopeMeasurement, uuid : UUID) {
        gyroscopeController.addData(name: "Gyroscope", measurement: measurement)
    }
    
    func ReadyForCalibration(uuid : UUID) {
        /** This is called many many times **/
        if(!settingsButton.isEnabled){
            player.play(resource : .intro)
            settingsButton.isEnabled = true
        }
    }
    
    func Calibrated(values: [[Double]], uuid : UUID) {
        baselineButton.isEnabled = true
        dataCollectorButton.isEnabled = true
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

extension RecorderController : PredictionCollectorDelegate {
    func prediction(output: activityClassifierOutput) {
        self.predictionResults.stringValue = "Prediction Result : \(output.type)"
    }
}
