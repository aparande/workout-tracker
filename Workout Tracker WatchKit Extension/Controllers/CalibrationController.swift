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
        
        getWorkoutName(forCalibration: calibration)
    }
    
    private func getWorkoutName(forCalibration calibration: Calibration) {
        self.presentTextInputController(withSuggestions: nil, allowedInputMode: .plain) { (inputVal) in
            guard let name = inputVal?[0] as? String else {
                let cancelAction = WKAlertAction(title: "Yes", style: .destructive) {
                    DispatchQueue.main.async { self.dismiss() }
                }
                
                let nameAction = WKAlertAction(title: "No", style: .default) {
                    self.getWorkoutName(forCalibration: calibration)
                }
                
                self.presentAlert(withTitle: "Are you sure?", message: "If you do not give this exercise a name, it will not be saved", preferredStyle: .alert, actions: [cancelAction, nameAction])
                return
            }
            
            let exercise = Exercise(name: name, calibration: calibration)
            var exercises = [exercise]
            
            if let exerciseData = UserDefaults.standard.data(forKey: UserDefaultsKeys.exercises) {
                exercises.append(contentsOf: (try? PropertyListDecoder().decode([Exercise].self, from: exerciseData)) ?? [])
            }
            
            UserDefaults.standard.set(try? PropertyListEncoder().encode(exercises), forKey: UserDefaultsKeys.exercises)
            self.dismiss()
        }
    }
}
