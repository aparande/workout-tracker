//
//  DifferenceFilter.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/28/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation

/**
 Struct for a difference filter
 Impulse response is h[n] = delta[n] - delta[n-1] if direction is positive
 Impulse response is h[n] = -delta[n] + delta[n-1] if direction is negative
 */
struct DifferenceFilter: Filter {
    /**
     Encode the direction of the filter
     */
    enum Direction: Int, Codable {
        case positive = 1, negative = -1
        
        static let all:[Direction] = [.positive, .negative]
    }
    
    /** Difference filters only require 1 unit of memory */
    var memory: [Double] = [0]
    let direction: Direction
    
    /** If we have filtered 1 value or fewer, our output is invalid */
    var hasBoundaryEffect: Bool { return filteredValues <= 1 }
    private var filteredValues: Int = 0

    init(withDirection direction: Direction) {
        self.direction = direction
    }
    
    mutating func filter(_ x: Double) -> Double {
        let out = Double(self.direction.rawValue) * (x - memory[0])
        self.memory[0] = x
        filteredValues += 1
        return out
    }
    
    mutating func filter(signal: [Double]) -> [Double] {
        var out:[Double] = []
        
        for (i, val) in signal.enumerated() {
            let y = filter(val)
            if i != 0 {
                out.append(y)
            }
        }
        
        return out
    }
}
