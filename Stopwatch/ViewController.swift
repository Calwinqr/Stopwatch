//
//  ViewController.swift
//  Stopwatch
//
//  Created by Calwin on 12/09/24.
//

import UIKit

class ViewController: UIViewController {

    class Stopwatch: NSObject{
        var counter: Double
        var timer: Timer
        
        override init() {
            counter=0.0
            timer=Timer()
        }
    }
    
    let mainStopwatch: Stopwatch = Stopwatch()
    let lapStopwatch: Stopwatch = Stopwatch()
    var isPlay = false
    var laps: [String] = []
    
    @IBOutlet weak var mainStopwatchLabel: UILabel!
    @IBOutlet weak var lapStopwatchLabel: UILabel!
    @IBOutlet weak var playStopBtn: UIButton!
    @IBOutlet weak var lapResetBtn: UIButton!
    @IBOutlet weak var lapsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lapsTableView.dataSource=self
        lapsTableView.delegate=self
        
        lapResetBtn.isEnabled = false
        //Circle button edit:
        
    }
    
    override var shouldAutorotate: Bool{
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.portrait
    }
    
    @IBAction func playStopBtnPressed(_ sender: UIButton) {
        lapResetBtn.isEnabled=true
        
        changeBtn(lapResetBtn, to: "Lap", withColor: UIColor.blue)
        
        if !isPlay{
            mainStopwatch.timer = Timer.scheduledTimer(timeInterval: 0.035, target: self, selector: #selector(updateMainTimer), userInfo: nil, repeats: true)
            lapStopwatch.timer = Timer.scheduledTimer(timeInterval: 0.035, target: self, selector: #selector(updateLapTimer), userInfo: nil, repeats: true)
            
            RunLoop.current.add(mainStopwatch.timer, forMode: RunLoop.Mode.common)
            RunLoop.current.add(lapStopwatch.timer, forMode: RunLoop.Mode.common)
            
            isPlay=true
            changeBtn(playStopBtn, to: "Stop", withColor: UIColor.red)
        }
        else{
            mainStopwatch.timer.invalidate()
            lapStopwatch.timer.invalidate()
            isPlay=false
            changeBtn(playStopBtn, to: "Start", withColor: UIColor.green)
            changeBtn(lapResetBtn, to: "Reset", withColor: UIColor.black)
        }
    }
    
    @IBAction func lapResetBtnPressed(_ sender: UIButton) {
        if !isPlay{
            resetLapTimer()
            resetMainTimer()
            changeBtn(lapResetBtn, to: "Lap", withColor: UIColor.blue)
            lapResetBtn.isEnabled=false
        }
        else{
            if let time=lapStopwatchLabel.text{
                laps.append(time)
            }
            lapsTableView.reloadData()
            resetLapTimer()
            lapStopwatch.timer = Timer.scheduledTimer(timeInterval: 0.035, target: self, selector: #selector(updateLapTimer), userInfo: nil, repeats: true)
            RunLoop.current.add(lapStopwatch.timer, forMode: RunLoop.Mode.common)
        }
    }
    
    //Helper functions:
    func changeBtn(_ button: UIButton,to name: String, withColor color: UIColor){
        button.setTitle(name, for: .normal)
        button.setTitleColor(color, for: .normal)
    }
    
    @objc func updateMainTimer(){
        updateTimer(mainStopwatch, mainStopwatchLabel)
    }
    
    @objc func updateLapTimer(){
        updateTimer(lapStopwatch, lapStopwatchLabel)
    }
    
    func updateTimer(_ stopwatch: Stopwatch, _ label: UILabel){
        stopwatch.counter += 0.035
        
        var minutes = String((Int)(stopwatch.counter / 60))
        var seconds = String(format: "%.2f", (stopwatch.counter.truncatingRemainder(dividingBy: 60)))
        if (Int)(stopwatch.counter / 60) < 10{
            minutes = "0"+minutes
        }
        if (stopwatch.counter.truncatingRemainder(dividingBy: 60)) < 10{
            seconds = "0"+seconds
        }
        label.text = minutes+":"+seconds
    }
    
    func resetMainTimer(){
        mainStopwatch.timer.invalidate()
        mainStopwatch.counter=0.0
        mainStopwatchLabel.text="00:00:00"
        laps.removeAll()
        lapsTableView.reloadData()
    }
    
    func resetLapTimer(){
        lapStopwatch.timer.invalidate()
        lapStopwatch.counter=0.0
        lapStopwatchLabel.text="00:00:00"
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        laps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lap = tableView.dequeueReusableCell(withIdentifier: "lap", for: indexPath)
        if let labelNum = lap.viewWithTag(11) as? UILabel {
              labelNum.text = "Lap \(laps.count - indexPath.row)"
        }
        if let labelTimer = lap.viewWithTag(12) as? UILabel {
            labelTimer.text = laps[laps.count - indexPath.row - 1]
        }
        return lap
    }
}
