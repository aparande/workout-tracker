//
//  MaximumFilter.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/28/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation

struct MaximumFilter: Filter {
    var memory: [Double]
    private var absMemory: [Double]
    
    var hasBoundaryEffect: Bool { return filteredValues <= 25 }
    
    private var filteredValues: Int = 0
    
    init(withWindow window: Int) {
        memory = Array(repeating: 0, count: window)
        absMemory = Array(repeating: 0, count: window)
    }
    
    mutating func filter(_ x: Double) -> Double {
        let _ = memory.removeFirst()
        let _ = absMemory.removeFirst()
        
        memory.append(x)
        absMemory.append(abs(x))
        
        filteredValues += 1
        
        guard let maxIdx = absMemory.argmax() else { return 0}
        return memory[maxIdx]
    }
    
    mutating func filter(signal: [Double]) -> [Double] {
        return signal.map { self.filter($0) }
    }
}
