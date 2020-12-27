//
//  CalibrationManager.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/24/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation

class CalibrationManager: WorkoutManager {
    let WORKOUT_TYPE: SessionType = .calibration
    
    let targetReps: Int
    
    init(withTarget repCount: Int) {
        self.targetReps = repCount
        
        super.init(withDetector: nil)
    }
    
    override func startWorkout() {
        super.startWorkout()
        
        // Set a timer to buzz the user to change state
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
            switch self.state {
            case .up:
                if self.repNumber == self.targetReps {
                    self.stopWorkout()
                    self.delegate?.workoutStateUpdated(self, repNumber: self.repNumber, state: self.state, workoutComplete: true)
                    timer.invalidate()
                    return
                }
                
                self.repNumber += 1
                self.state = .down
                self.delegate?.workoutStateUpdated(self, repNumber: self.repNumber, state: self.state, workoutComplete: false)
            case .down:
                self.state = .up
                self.delegate?.workoutStateUpdated(self, repNumber: self.repNumber, state: self.state, workoutComplete: false)
            }
        }
    }
}
