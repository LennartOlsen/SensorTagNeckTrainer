//
//  DataCollector.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 30/03/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Cocoa

class DataCollector: NSViewController {
    private var isCollecting = false
    private var dataCollector : Collector!
    var devices : [UUID : SensorTagPeripheral]?
    var collectionType : DataEntryTypes = .tiltLeft
    
    var repos : LocalRepository = LocalRepository()
    
    @IBOutlet weak var startCollectionButton: NSButton!
    @IBOutlet weak var debugView: NSTextView!
    @IBOutlet weak var typeComboBox: NSComboBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.dataCollector = Collector(devices: self.devices!, delegate:self)
        for type in DataEntryTypes.allReversible {
            typeComboBox.addItem(withObjectValue: type.rawValue)
        }
        typeComboBox.selectItem(at: 0)
    }
    
    @IBAction func doCollection(_ sender: Any) {
        guard let c = dataCollector else {
            return
        }
        typeComboBox.isEnabled = false
        c.doCollect(count: 10, type: collectionType)
    }
    @IBAction func selectType(_ sender: Any) {
        collectionType = DataEntryTypes.allReversible[typeComboBox.indexOfSelectedItem]
    }
}

extension DataCollector : CollectorListenerDelegate {
    func collectionIsFinished(dataEntry: DataEntry) {
        typeComboBox.isEnabled = true
        print("collection finished")
        for c in dataEntry.collections {
            let v = c.asArray()
            let csv = "\(dataEntry.type),\(v[3]),\(v[4]),\(v[5]),\(v[6]),\(v[7]),\(v[8]),\(dataEntry.collectionId)\n"
            debugView.string = debugView.string + csv
            repos.update(data: csv)
        }
        
    }
}
