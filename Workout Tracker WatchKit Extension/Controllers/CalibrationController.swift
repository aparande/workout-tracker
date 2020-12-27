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

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.workoutManager = CalibrationManager(withTarget: context! as! Int)
        self.workoutManager.delegate = self
    }
    
    // MARK: Interface Bindings
    
    @IBAction override func start() {
        controlButton.setEnabled(false)
        WKInterfaceDevice().play(.start)
        workoutManager.startWorkout()
    }
}
