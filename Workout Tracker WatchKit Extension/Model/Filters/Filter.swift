//
//  Filter.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/28/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation

/** Generic protocol which all filters follow */
protocol Filter {
    var memory: [Double] { get set }
    var hasBoundaryEffect: Bool { get }
    
    /** Get the output given an input */
    mutating func filter(_ x: Double) -> Double
    
    /** Causally filter an array of data */
    mutating func filter(signal: [Double]) -> [Double]
}
