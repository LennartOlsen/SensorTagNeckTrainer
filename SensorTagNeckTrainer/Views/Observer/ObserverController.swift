//
//  LineChartController.swift
//  SensorTagNeckTrainer
//
//  Created by Lennart Olsen on 01/03/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Cocoa
import Charts

class ObserverController: NSView {
    var lineChartView: LineChartView!
    
    private var cutOff = 30.0
    private var lowX = 0.0
    private var x = 0.0
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    func setUpLineChart(){
        lineChartView = LineChartView()
        
        self.addSubview(lineChartView)
        
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lineChartView.topAnchor.constraint(equalTo: self.topAnchor),
            lineChartView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            lineChartView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            lineChartView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
    func addData(name : String, measurement : Measurement){
        let data = LineChartData()
        
        let x = ChartDataEntry(x: self.x, y: Double(measurement.x))
        let xSet = LineChartDataSet(values: [x], label: "X")
        xSet.drawCirclesEnabled = false
        xSet.lineWidth = 3
        xSet.colors = [Colors.GraphXLine!]
        xSet.fillColor = Colors.GraphXLine!
        xSet.valueColors = [Colors.GraphXLine!]
        
        let y = ChartDataEntry(x: self.x, y: Double(measurement.y))
        let ySet = LineChartDataSet(values: [y], label: "Y")
        ySet.drawCirclesEnabled = false
        ySet.lineWidth = 3
        ySet.colors = [Colors.GraphYLine!]
        ySet.fillColor = Colors.GraphYLine!
        ySet.valueColors = [Colors.GraphYLine!]
        
        let z = ChartDataEntry(x: self.x, y: Double(measurement.z))
        let zSet = LineChartDataSet(values: [z], label: "Z")
        zSet.drawCirclesEnabled = false
        zSet.lineWidth = 3
        zSet.colors = [Colors.GraphZLine!]
        zSet.fillColor = Colors.GraphZLine!
        zSet.valueColors = [Colors.GraphZLine!]
        
        if lineChartView.data == nil {
            data.addDataSet(xSet)
            data.addDataSet(ySet)
            data.addDataSet(zSet)
            lineChartView.data = data
            lineChartView.chartDescription?.text = name
            lineChartView.chartDescription?.font = Fonts.Text!
            lineChartView.backgroundColor = Colors.Darken
            lineChartView.xAxis.drawGridLinesEnabled = false
            lineChartView.xAxis.drawAxisLineEnabled = false
        } else {
            lineChartView.data?.addEntry(x, dataSetIndex: 0)
            lineChartView.data?.addEntry(y, dataSetIndex: 1)
            lineChartView.data?.addEntry(z, dataSetIndex: 2)
            
            if( lowX >= 0 ){
                lineChartView.data?.removeEntry(xValue: lowX, dataSetIndex: 0)
                lineChartView.data?.removeEntry(xValue: lowX, dataSetIndex: 1)
                lineChartView.data?.removeEntry(xValue: lowX, dataSetIndex: 2)
            }
        }
        
        //This must stay at end of function
        lineChartView.notifyDataSetChanged()
        self.x += 1.0
        lowX = self.x - cutOff
    }
}
