/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This class is responsible for managing interactions with the interface.
 */

import WatchKit
import WatchConnectivity
import Foundation
import Dispatch

class CalibrationController: WorkoutController {
    // MARK: Properties
    override var WORKOUT_TYPE: SessionType { return .calibration }
    var calibrationManager: CalibrationManager!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.calibrationManager = CalibrationManager(withTarget: context! as! Int)
        self.calibrationManager.delegate = self
        self.workoutManager = self.calibrationManager
    }
    
    // MARK: Interface Bindings
    
    @IBAction override func start() {
        controlButton.setEnabled(false)
        WKInterfaceDevice().play(.start)
        calibrationManager.startWorkout()
    }
    
    override func workoutEnded(_ manager: WorkoutManager, sessionData: [MotionData]?) {
        // Start Processing The Data
        guard let data = sessionData else { return }
        let calibration = calibrationManager.calibrate(data)
        print("Finished calibration: \(calibration)")
        try? self.save(jsonData: WorkoutData(calibration: calibration, motion: data), toFileNamed: "\(self.WORKOUT_TYPE.rawValue)-\(Date().datetime)")

        UserDefaults.standard.set(try? PropertyListEncoder().encode(calibration), forKey: "calibration")
    }
}
