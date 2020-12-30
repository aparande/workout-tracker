//
//  Enums.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/29/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation

enum State:String {
    case up = "Up", down = "Down"
}

enum SessionType:String {
    case counting, calibration
}

enum SignalType: String, Codable {
    case gravityX, gravityY, gravityZ
}
