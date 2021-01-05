//
//  CalibrationManager.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/24/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation
import os.log

/**
 Subclass of WorkoutManager that specifically deals with calibrating exercises
 */
class CalibrationManager: WorkoutManager {
    typealias Peak = (offset: Int, element: Double)
    
    let MAX_WINDOW = 25
    
    /** The number of calibration repetitions*/
    let targetReps: Int
    
    init(withTarget repCount: Int) {
        self.targetReps = repCount
        
        super.init(withDetector: nil)
    }
    
    override func startWorkout() {
        super.startWorkout()
        
        // Set a timer to guide the user when to change state
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
            switch self.state {
            case .rest:
                if self.repNumber == self.targetReps {
                    self.stopWorkout()
                    self.delegate?.workoutStateUpdated(self, repNumber: self.repNumber, state: self.state, workoutComplete: true)
                    timer.invalidate()
                    return
                }
                
                self.repNumber += 1
                self.state = .flexed
                self.delegate?.workoutStateUpdated(self, repNumber: self.repNumber, state: self.state, workoutComplete: false)
            case .flexed:
                self.state = .rest
                self.delegate?.workoutStateUpdated(self, repNumber: self.repNumber, state: self.state, workoutComplete: false)
            }
        }
    }
    
    /**
     Learn detector parameters from the session data
     */
    func calibrate(_ motionData: [MotionData]) -> Calibration {
        // Collect the gravity signals in a dictionary
        let gravitySignals:[SignalType:[Double]] = [
            .gravityX: motionData.map {$0.gravityX},
            .gravityY: motionData.map {$0.gravityY},
            .gravityZ: motionData.map {$0.gravityZ}
        ]
        
        // Locate the transitions
        let transitions = motionData.map { $0.state }
        
        var detectors:[Calibration] = []
        for (type, signal) in gravitySignals {
            for direction in DifferenceFilter.Direction.all {
                // Apply a difference filter to the data
                var filter = DifferenceFilter(withDirection: direction)
                let filteredSignal = filter.filter(signal: signal)
                
                // Detect peaks in the data
                let peaks = getPeaks(in: filteredSignal)
                
                // Select an optimal threshold
                let (threshold, margin) = selectThreshold(for: filteredSignal, givenTransitions: transitions, andPeaks: peaks)
                
                // Detect peaks considering the threshold
                let truePeaks = getPeaks(in: filteredSignal, withThreshold: threshold)
                
                // Measure the detector quality (lower quality number is better)
                let quality = measureQuality(of: truePeaks, givenTransitions: transitions)
                
                detectors.append(Calibration(signal: type, threshold: threshold, direction: direction, margin: margin, quality: quality))
            }
        }
        
        // Use the minimum quality with the maximum "margin"
        let bestQuality = detectors.min { $0.quality < $1.quality }!.quality
        return detectors.filter { $0.quality == bestQuality }.max { $0.margin < $1.margin }!
    }
    
    /**
     Run a peak detection algorithm on the signal with an optional threshold for how large a peak is
     */
    private func getPeaks(in signal: [Double], withThreshold thresh: Double = 0) -> [Peak] {
        // Apply an absolute maximum value filter
        var maxFilter = MaximumFilter(withWindow: MAX_WINDOW)
        let maxSignal = maxFilter.filter(signal: signal)
        
        // Peaks are when the signal is equal to the maximum filter output and larger than the threshold
        return signal.enumerated().filter { $0.element == maxSignal[$0.offset] && abs($0.element) >= thresh }
    }
    
    /**
     Select a detection threshold using the peaks and known transition locations
     */
    private func selectThreshold(for signal: [Double], givenTransitions transitions: [String?], andPeaks peaks: [Peak]) -> (threshold: Double, margin: Double) {
        let transitionLocs = getTransitionLocs(from: transitions)
        var truePeakLocs: [Bool] = Array(repeating: false, count: peaks.count)
        
        for (idx, loc) in transitionLocs.enumerated() {
            // Get all peaks that exist between two state transitions
            let candidatePeaks = peaks.enumerated().filter { $0.element.offset >= loc && (idx + 1 >= transitionLocs.count || $0.element.offset < transitionLocs[idx + 1]) }
            
            // Let the true peak be the largest of these peaks
            guard let truePeakIdx = candidatePeaks.map({ abs($0.element.element) }).argmax() else {
                os_log("Found no peaks between calibrated transitions")
                continue
            }
            truePeakLocs[candidatePeaks[truePeakIdx].offset] = true
        }
        
        // Compute the mean of the true peaks and the mean of the "false" peaks
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
    
    /**
     Find the indices of the state transitions in the data
     */
    private func getTransitionLocs(from transitions:[String?]) -> [Int] {
        return transitions.enumerated().filter { $0.offset != 0 && $0.element != transitions[$0.offset - 1] }.map { $0.offset }
    }
    
    /**
     Using peaks (estimated transitions) and true transitions, see how accurate the detector would be on the calibration data.
     */
    private func measureQuality(of peaks: [Peak], givenTransitions transitions:[String?]) -> Int {
        let trueReps = getTransitionLocs(from: transitions).count
        
        var state:State = .rest
        var estimatedReps = 0
        for (_, element) in peaks {
            if state == .rest && element < 0 {
                state = .flexed
                estimatedReps += 1
            } else if state == .flexed && element > 0 {
                state = .rest
                estimatedReps += 1
            }
        }
        
        return abs(trueReps - estimatedReps)
    }
}
