//
//  CalibrationManager.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/24/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation
import os.log

class CalibrationManager: WorkoutManager {
    typealias Peak = (offset: Int, element: Double)
    
    let MAX_WINDOW = 25
    
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
    
    func calibrate(_ motionData: [MotionData]) -> Calibration {
        let gravitySignals:[SignalType:[Double]] = [
            .gravityX: motionData.map {$0.gravityX},
            .gravityY: motionData.map {$0.gravityY},
            .gravityZ: motionData.map {$0.gravityZ}
        ]
        
        let transitions = motionData.map { $0.state }
        
        var detectors:[Calibration] = []
        
        for (type, signal) in gravitySignals {
            for direction in DifferenceFilter.Direction.all {
                var filter = DifferenceFilter(withDirection: direction)
                let filteredSignal = filter.filter(signal: signal)
                let peaks = getPeaks(in: filteredSignal)
                
                let (threshold, margin) = selectThreshold(for: filteredSignal, givenTransitions: transitions, andPeaks: peaks)
                let truePeaks = getPeaks(in: filteredSignal, withThreshold: threshold)
                let quality = measureQuality(of: truePeaks, givenTransitions: transitions)
                
                detectors.append(Calibration(signal: type, threshold: threshold, direction: direction, margin: margin, quality: quality))
            }
        }
        
        let bestQuality = detectors.min { $0.quality < $1.quality }!.quality
        return detectors.filter { $0.quality == bestQuality }.max { $0.margin < $1.margin }!
    }
    
    private func getPeaks(in signal: [Double], withThreshold thresh: Double = 0) -> [Peak] {
        var maxFilter = MaximumFilter(withWindow: MAX_WINDOW)
        let maxSignal = maxFilter.filter(signal: signal) // Computes absolute maximum value filter
        
        return signal.enumerated().filter { $0.element == maxSignal[$0.offset] && abs($0.element) >= thresh }
    }
    
    private func selectThreshold(for signal: [Double], givenTransitions transitions: [String?], andPeaks peaks: [Peak]) -> (threshold: Double, margin: Double) {
        let transitionLocs = getTransitionLocs(from: transitions)
        var truePeakLocs: [Bool] = Array(repeating: false, count: peaks.count)
        
        for (idx, loc) in transitionLocs.enumerated() {
            // Inefficiency but deal with it for now
            let candidatePeaks = peaks.enumerated().filter { $0.element.offset >= loc && (idx + 1 >= transitionLocs.count || $0.element.offset < transitionLocs[idx + 1]) }
            guard let truePeakIdx = candidatePeaks.map({ abs($0.element.element) }).argmax() else {
                os_log("Found no peaks between calibrated transitions")
                continue
            }
            truePeakLocs[candidatePeaks[truePeakIdx].offset] = true
        }
        
        var truePeakMean = 0.0, falsePeakMean = 0.0
        var truePeakCount = 0.0, falsePeakCount = 0.0
        
        for (idx, val) in truePeakLocs.enumerated() {
            if val {
                truePeakMean += abs(peaks[idx].element)
                truePeakCount += 1.0
            } else {
                falsePeakMean += abs(peaks[idx].element)
                falsePeakCount += 1.0
            }
        }
        
        truePeakMean /= truePeakCount
        falsePeakMean /= falsePeakCount
        
        // Threshold and Margin
        return ((truePeakMean + falsePeakMean) / 2, (truePeakMean - falsePeakMean) / 2)
    }
    
    private func getTransitionLocs(from transitions:[String?]) -> [Int] {
        return transitions.enumerated().filter { $0.offset != 0 && $0.element != transitions[$0.offset - 1] }.map { $0.offset }
    }
    
    private func measureQuality(of peaks: [Peak], givenTransitions transitions:[String?]) -> Int {
        let trueReps = getTransitionLocs(from: transitions).count
        
        var state:State = .up
        var estimatedReps = 0
        for (_, element) in peaks {
            if state == .up && element < 0 {
                state = .down
                estimatedReps += 1
            } else if state == .down && element > 0 {
                state = .up
                estimatedReps += 1
            }
        }
        
        return abs(trueReps - estimatedReps)
    }
}
