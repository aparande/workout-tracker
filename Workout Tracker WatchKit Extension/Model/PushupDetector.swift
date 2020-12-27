//
//  PushupProcessor.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/24/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation

extension Array where Element: Comparable {
    func argmax() -> Index? {
        // https://gist.github.com/bdsaglam/b41294540756768f26dca70d058f8e1e
        return indices.max(by: { self[$0] < self[$1] })
    }
}


class PushupDetector {
    static let MAX_WINDOW = 25
    static let PEAK_THRESH = 0.01
    
    var buffer: [Double] = []
    var prevData: Double?
    
    var state: State = .up
    
    // Returns the pushup stage we think we are in
    func detect(from data: MotionData) -> State {
        let gravityY = data.gravityY
        
        guard let prev = prevData else {
            prevData = gravityY
            return self.state
        }
        
        // Two Point Difference Filter h[n] = -delta[n] + delta[n-1]
        buffer.append(prev - gravityY)
        
        if buffer.count < PushupDetector.MAX_WINDOW { return self.state }
        else if buffer.count > PushupDetector.MAX_WINDOW { buffer.remove(at: 0) }
        
        guard let peakIdx = buffer.argmax() else { return self.state }
        
        let peak = buffer[peakIdx]
        if abs(peak) >= PushupDetector.PEAK_THRESH {
            self.state = peak > 0 ? .up : .down
        }
        
        
        return self.state
    }
}
