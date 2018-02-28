//
//  IntialView.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 26/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Cocoa
import CoreBluetooth

class ConnectController: NSViewController {
    
    private var pm = PeripheralManager.sharedInstance //singleton
    
    private var discoveredDevice : CBPeripheral!
    var sensorTag : SensorTagPeripheral!
    
    @IBOutlet weak var infoLabel: NSTextField!
    
    @IBOutlet weak var connectButton: NSButton!
    var owningDelegate : OwningViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectButton.isEnabled = false
        pm.listenerDelegate = self
    }
    
    override func viewDidDisappear() {
        owningDelegate?.willDestroy(sender: self)
    }
    
    @IBAction func doConnect(_ sender: Any) {
        pm.connectToDevice(uuid: discoveredDevice.identifier)
        infoLabel.stringValue = "Connecting"
    }
}

extension ConnectController : BluetoothListenerDelegate  {
    
    func didDiscover(peripheralDevice: CBPeripheral) {
        if( SensorTagPeripheral.validateSensorTag(device : peripheralDevice) ){
            infoLabel.stringValue = "Click headset to connect"
            connectButton.isEnabled = true
            
            discoveredDevice = peripheralDevice
            
            pm.stopScan()
        }
    }
    
    func didConnect(peripheralDevice: CBPeripheral) {
        if SensorTagPeripheral.validateSensorTag(device: peripheralDevice) {
            infoLabel.stringValue = "Connected to device. Closing in 1"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.infoLabel.stringValue = "Connected to device. Closing in 0"
                self.dismissViewController(self)
            }
        }
    }
}
