//
//  Timer.swift
//  Nightlapse
//
//  Created by Modestas Valauskas on 27.06.15.
//  Copyright (c) 2015 ModestasV Studios. All rights reserved.
//

import Foundation
import UIKit

class Timer {
    
    var timer:NSTimer? = nil
    var times:Int = 0

    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "onTick:", userInfo: nil, repeats: false)
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
    func onTick(timer: NSTimer, takePicture: (), shootButton: UIButton) {
        times += 1
        if times < 201 {
            takePicture
            shootButton.setTitle("\(times)", forState: UIControlState.Normal)
            self.startTimer()
        } else {
            stopTimer(shootButton)
        }
    }
    
    func stopTimer(shootButton: UIButton) {
        self.timer?.invalidate()
        shootButton.setTitle("O", forState: UIControlState.Normal)
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
}