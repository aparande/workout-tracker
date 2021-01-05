//
//  MaximumFilter.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/28/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation

/**
 Struct for a Maximum Filter.
 This filter considers the magnitude when taking the maximum (i.e absolute value), but its output maintains the same sign.
 */
struct MaximumFilter: Filter {
    var memory: [Double]
    private var absMemory: [Double]
    
    // If the memory buffer is not full, then there is a boundary effect
    var hasBoundaryEffect: Bool { return filteredValues <= memory.count }
    
    private var filteredValues: Int = 0
    
    init(withWindow window: Int) {
        memory = Array(repeating: 0, count: window)
        absMemory = Array(repeating: 0, count: window)
    }
    
    mutating func filter(_ x: Double) -> Double {
        // Remove a value from memory
        let _ = memory.removeFirst()
        let _ = absMemory.removeFirst()
        
        // Add the current value to memory
        memory.append(x)
        absMemory.append(abs(x))
        
        filteredValues += 1
        
        // Find the absolute maximum and then return that value with the correct sign
        guard let maxIdx = absMemory.argmax() else { return 0 }
        return memory[maxIdx]
    }
    
    mutating func filter(signal: [Double]) -> [Double] {
        return signal.map { self.filter($0) }
    }
}
