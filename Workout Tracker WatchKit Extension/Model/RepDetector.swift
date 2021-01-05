//
//  PushupProcessor.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/24/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation

/**
 Repetition Detector class
 */
class RepDetector {
    static let MAX_WINDOW = 25
    static let PEAK_THRESH = 0.01

    /** Internal state of the detector */
    private var state: State = .rest
    
    private let calibration: Calibration
    private var differenceFilter: DifferenceFilter
    private var maxFilter: MaximumFilter = MaximumFilter(withWindow: MAX_WINDOW)
    
    /** Initialize the detector with a particular calibration */
    init(withCalibration calibration: Calibration) {
        self.calibration = calibration
        self.differenceFilter = DifferenceFilter(withDirection: calibration.direction)
    }
    
    /** Return the rep state the detector believes it is in based on a new data point */
    func detect(from data: MotionData) -> State {
        // Apply a difference filter to the data point
        let difference = self.differenceFilter.filter(getSignal(from: data))
        
        // Ignore boundary effects
        if self.differenceFilter.hasBoundaryEffect {
            return self.state
        }
        
        // Apply a maximum filter (for peak detection)
        let peak = maxFilter.filter(difference)
        
        // If there was a transition and it was not a boundary effect, change the state according to the peak direction
        if !maxFilter.hasBoundaryEffect && abs(peak) >= calibration.threshold {
            self.state = peak > 0 ? .rest : .flexed
        }
                
        return self.state
    }
    
    /** Extract the desired signal from the data */
    private func getSignal(from data: MotionData) -> Double {
        switch self.calibration.signal {
        case .gravityX:
            return data.gravityX
        case .gravityY:
            return data.gravityY
        case  .gravityZ:
            return data.gravityZ
        }
    }
}
