//
//  IntialView.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 26/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Cocoa
import CoreBluetooth

let CONNECT_TO = 2

class ConnectController: NSViewController {
    
    private var pm = PeripheralManager.sharedInstance //singleton
    
    private var discoveredDevices = [UUID : CBPeripheral]()
    
    var sensorTags = [UUID : SensorTagPeripheral]()
    
    
    var sduDevice : SDUPeripheral!
    
    @IBOutlet weak var infoLabel: NSTextField!
    
    @IBOutlet weak var connectButton: NSButton!
    var owningDelegate : OwningViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectButton.isEnabled = false
        pm.listenerDelegate = self
        infoLabel.textColor = Colors.Text
    }
    
    override func viewDidDisappear() {
        owningDelegate?.willDestroy(sender: self)
    }
    
    @IBAction func doConnect(_ sender: Any) {
        for (uuid, _) in discoveredDevices {
            pm.connectToDevice(uuid: uuid)
        }
        infoLabel.stringValue = "Connecting, make sure both sensor are on"
        
        pm.stopScan()
    }
}

extension ConnectController : BluetoothListenerDelegate  {
    
    func didDiscover(peripheralDevice: CBPeripheral) {
        if( SensorTagPeripheral.validateSensorTag(device : peripheralDevice) ){
            self.discoveredDevices[peripheralDevice.identifier] = peripheralDevice
            infoLabel.stringValue = "Still searcing, found \(discoveredDevices.count) sensor(s)"
            if( self.discoveredDevices.count == CONNECT_TO ){
                infoLabel.stringValue = "Click headset to connect"
                connectButton.isEnabled = true
            }
        }
    }
    
    func didConnect(peripheralDevice: CBPeripheral) {
        if SensorTagPeripheral.validateSensorTag(device: peripheralDevice)  {
            sensorTags[peripheralDevice.identifier] = SensorTagPeripheral(device : peripheralDevice)
            infoLabel.stringValue = "Connected to sensor, \(sensorTags.count) of \(CONNECT_TO)"
            if(sensorTags.count == CONNECT_TO){
                infoLabel.stringValue = "Connected to sensors. Closing in 1"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.infoLabel.stringValue = "Connected to sensors. Closing in 0"
                    self.dismissViewController(self)
                }
            }
        }
    }
}
