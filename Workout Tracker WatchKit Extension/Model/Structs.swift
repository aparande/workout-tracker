//
//  Structs.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/29/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation

struct MotionData: Codable {
    let timestamp: Int64
    var state: String? = nil
    
    let gravityX: Double
    let gravityY: Double
    let gravityZ: Double
    
    let accelX: Double
    let accelY: Double
    let accelZ: Double
    
    let rotX: Double
    let rotY: Double
    let rotZ: Double
    
    let roll: Double
    let pitch: Double
    let yaw: Double
}

struct Calibration: Codable {
    let signal: SignalType
    let threshold: Double
    let direction: DifferenceFilter.Direction
    let margin: Double
    let quality: Int
}

struct WorkoutData: Codable {
    let calibration: Calibration
    let motion: [MotionData]
}
