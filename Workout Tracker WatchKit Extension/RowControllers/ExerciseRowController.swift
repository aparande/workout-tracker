//
//  ExerciseRowController.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/31/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation
import WatchKit

class ExerciseRowController: NSObject {
    @IBOutlet var exerciseNameLabel: WKInterfaceLabel!
    
    var exercise: Exercise? {
        didSet {
            let name = exercise?.name ?? "Add Exercise"
            self.exerciseNameLabel.setText(name)
        }
    }
}
