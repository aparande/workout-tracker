//
//  Filter.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/28/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation

protocol Filter {
    var memory: [Double] { get set }
    var hasBoundaryEffect: Bool { get }
    
    mutating func filter(_ x: Double) -> Double
    mutating func filter(signal: [Double]) -> [Double]
}
