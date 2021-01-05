//
//  WorkoutController.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/24/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation
import Dispatch

/**
 Interface controller for calibration. Subclass of WorkoutController
 */
class CalibrationController: WorkoutController {
    override var WORKOUT_TYPE: SessionType { return .calibration }
    var calibrationManager: CalibrationManager!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.calibrationManager = CalibrationManager(withTarget: context! as! Int)
        self.calibrationManager.delegate = self
        self.workoutManager = self.calibrationManager
    }
        
    /** Begin the calibration workout */
    @IBAction override func start() {
        controlButton.setEnabled(false)
        WKInterfaceDevice().play(.start)
        self.workoutInSession = true
        calibrationManager.startWorkout()
    }
    
    /** Once the workout is over, find and save the detector */
    override func workoutEnded(_ manager: WorkoutManager, sessionData: [MotionData]?) {
        // Start Processing The Data
        guard let data = sessionData else { return }
        let calibration = calibrationManager.calibrate(data)
        print("Finished calibration: \(calibration)")
        try? self.save(jsonData: WorkoutData(calibration: calibration, motion: data), toFileNamed: "\(self.WORKOUT_TYPE.rawValue)-\(Date().datetime)")
        
        if let plistData = try? PropertyListEncoder().encode(calibration) {
            UserDefaults.standard.set(plistData, forKey: "calibration")
        }
        
        self.popToRootController()
        self.workoutInSession = false
    }
}
