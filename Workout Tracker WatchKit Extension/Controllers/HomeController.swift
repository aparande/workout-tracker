//
//  HomeController.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/31/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation
import WatchKit

class HomeController: WKInterfaceController {
    var exercises: [Exercise] = []
    
    @IBOutlet var exerciseTable: WKInterfaceTable!
    
    override func willActivate() {
        if let exerciseData = UserDefaults.standard.data(forKey: UserDefaultsKeys.exercises) {
            exercises = (try? PropertyListDecoder().decode([Exercise].self, from: exerciseData)) ?? []
        }
        
        var rowTypes = Array(repeating: "ExerciseRow", count: exercises.count)
        rowTypes.append("CalibrationRow")
        
        exerciseTable.setRowTypes(rowTypes)
        
        for idx in 0..<exerciseTable.numberOfRows {
            if idx < self.exercises.count {
                guard let controller = exerciseTable.rowController(at: idx) as? ExerciseRowController else { continue }
                controller.exercise = self.exercises[idx]
            }
        }
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        switch segueIdentifier {
        case "go_to_exercise":
            return self.exercises[rowIndex]
        case "go_to_calibration":
            return 5
        default:
            return nil
        }
    }
}
