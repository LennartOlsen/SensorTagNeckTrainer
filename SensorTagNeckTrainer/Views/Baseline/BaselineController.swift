//
//  BaselineController.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 19/03/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Cocoa

class BaselineController: NSViewController {

    @IBOutlet weak var headlineLabel: NSTextField!
    @IBOutlet weak var nextLabel: NSTextField!
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    
    @IBOutlet var debugView: NSTextView!
    
    var baseliner : Baseliner!
    
    var baselines = [Baseline]()
    
    var device : SensorTagPeripheral!
    
    var owningDelegate : OwningViewControllerDelegate!
    
    let player = SoundPlayer()
    var played = false
    
    @IBAction func doStartCollection(_ sender: Any) {
        baseliner = Baseliner(device : device, delegate : self)
        baseliner.start()
    }
    @IBAction func doStopCollection(_ sender: Any) {
        self.dismiss(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        headlineLabel.textColor = Colors.Text
        headlineLabel.font = Fonts.DisplayOne
        
        nextLabel.textColor = Colors.Text
        nextLabel.font = Fonts.DisplayTwo
    }
    
    override func viewDidDisappear() {
        if let d = owningDelegate {
            d.willDestroy(sender: self)
        }
        cleanup()
    }
    
    private func cleanup(){
        print("BaselineController cleanup")
        baseliner.stop()
        baseliner = nil
    }
    
}

extension BaselineController : BaselinerDelegate {
    func Next(type: DataEntryTypes, time: Int) {
        DispatchQueue.main.async {
            if(time == 2 && !self.played){
                self.played = true
                self.player.play(resource: DataEntryAudioResourceMap.get(dataEntryType: type))
            }
            self.nextLabel.stringValue = "Prepare for next type : \(type), in \(time)"
        }
    }
    
    func Start(type: DataEntryTypes, time: Int) {
        self.played = false
        DispatchQueue.main.async {
            self.nextLabel.stringValue = "Collecting type : \(type), for \(time)"
        }
    }
    
    func End(result: Baseline) {
        self.baselines.append(result)
        DispatchQueue.main.async {
            self.debugView.string = self.debugView.string + "\(result.type) : (min) \(result.minX) \(result.minY) \(result.minZ) : (avg) \(result.avgX) \(result.avgY) \(result.avgZ) : (max) \(result.maxX) \(result.maxY) \(result.maxZ) \n"
        }
    }
    
    func Completed(result : [Baseline]){
        self.baselines = result
        self.baseliner.stop()
        DispatchQueue.main.async {
            self.nextLabel.stringValue = "Done"
            self.stopButton.isEnabled = true
        }
    }
}
