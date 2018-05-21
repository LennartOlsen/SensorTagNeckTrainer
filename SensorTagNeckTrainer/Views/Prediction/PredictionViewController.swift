//
//  PredictionViewController.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 16/04/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Cocoa

class PredictionViewController: NSViewController {

    @IBOutlet weak var probailityCutoffSlider: NSSlider!
    @IBOutlet weak var probailityCutoffValue: NSTextField!
    
    @IBOutlet weak var predictionLabel: NSTextField!
    @IBOutlet weak var scoreLabel: NSTextField!
    @IBOutlet weak var timeLabel: NSTextField!
    
    @IBOutlet weak var probailityLevelIndicator: NSLevelIndicator!
    @IBOutlet weak var predictionProbailityLabel: NSTextField!
    
    @IBOutlet weak var scoreLevelIndicator: NSLevelIndicator!
    @IBOutlet weak var performanceCollectionButton: NSButton!
    var cutoff = 0.85
    
    @IBAction func onProbailityCutoffSliderSlide(_ sender: Any) {
        updateCutoff()
    }
    
    @IBAction func doPerformanceCollection(_ sender: Any) {
        if let pc = self.performanceController {
            if !isCollectingPerformance {
                pc.startPerformanceCollection()
                performanceCollectionButton.title = "Stop"
                isCollectingPerformance = true
            } else {
                pc.stopPerformanceCollection()
                performanceCollectionButton.title = "Start"
                isCollectingPerformance = false
            }
        }
    }
    
    var predictionCollector : PredictionCollector?
    var performanceController : PerformanceController?
    
    var isCollectingPerformance : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let pc = predictionCollector {
            pc.attach(observer : self)
            pc.startPrediction()
            
            performanceController = PerformanceController(predictionCollector: pc, delegate: self)
        }
        updateCutoff(true)
    }
    
    func updateCutoff(_ first : Bool = false){
        if(first){
            probailityCutoffSlider.doubleValue = cutoff
        }
        cutoff = probailityCutoffSlider.doubleValue
        probailityCutoffValue.stringValue = "\(cutoff)"
        probailityLevelIndicator.warningValue = cutoff * 100
        if(performanceController != nil){
            print("setting cutoff")
            performanceController?.setCutoff(cutoff)
        }
    }
    
    func evaluateResults(_ results : [PerformanceMetric], totalTime : Int){
        var goodTime = totalTime
        for r in results {
            if(r.Typ != DataEntryTypes.neutral.rawValue){
                goodTime -= r.totalTime
            }
        }
        var score = (Double(goodTime) / Double(totalTime)) * 100
        score = score.rounded()
        timeLabel.stringValue = "\(totalTime)"
        scoreLabel.stringValue = "\(score)"
        scoreLevelIndicator.doubleValue = Double(score / 10)
    }
    
    deinit{
        if let pc = predictionCollector {
            pc.remove(observer: self)
        }
    }
}

extension PredictionViewController : PredictionCollectorDelegate {
    func prediction( output : activityClassifierOutput ) {
        predictionLabel.stringValue = output.type
        if let prop = output.typeProbability[output.type] {
            let rounded = Double(round(1000*prop)/1000)
            
            predictionProbailityLabel.stringValue = "\(rounded)"
            probailityLevelIndicator.doubleValue = rounded * 100
        }
    }
    
    var id: String {
        get {
            return "PredictionViewController"
        }
    }
}

extension PredictionViewController : PerformanceControllerDelegate {
    func updatedMetric(result: PerformanceMetric, startTime: Int) {
        //print("got updated metric, \(startTime), the result \(result.Typ)")
    }
    
    func endedCollection(results: [PerformanceMetric], totalTime: Int) {
        // print("ended collection", totalTime)
        evaluateResults(results, totalTime: totalTime)
        isCollectingPerformance = false
    }
    
    
}
