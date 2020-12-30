//
//  PushupProcessor.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/24/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation

class RepDetector {
    static let MAX_WINDOW = 25
    static let PEAK_THRESH = 0.01
    
    var buffer: [Double] = []
    
    private var state: State = .up
    
    private let calibration: Calibration
    private var differenceFilter: DifferenceFilter
    private var maxFilter: MaximumFilter = MaximumFilter(withWindow: MAX_WINDOW)
    
    init(withCalibration calibration: Calibration) {
        self.calibration = calibration
        self.differenceFilter = DifferenceFilter(withDirection: calibration.direction)
    }
    
    // Returns the pushup stage we think we are in
    func detect(from data: MotionData) -> State {
        let difference = self.differenceFilter.filter(getSignal(from: data))
        
        // This is the first data point, so there will be a boundary effect
        if self.differenceFilter.hasBoundaryEffect {
            return self.state
        }
        
        let peak = maxFilter.filter(difference)
        
        if !maxFilter.hasBoundaryEffect && abs(peak) >= calibration.threshold {
            self.state = peak > 0 ? .up : .down
        }
                
        return self.state
    }
    
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
