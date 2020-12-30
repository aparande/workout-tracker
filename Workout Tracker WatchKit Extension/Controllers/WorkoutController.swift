//
//  WorkoutController.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/24/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import WatchKit
import WatchConnectivity

class WorkoutController: WKInterfaceController, WorkoutManagerDelegate {
    var WORKOUT_TYPE: SessionType { return .counting }
    
    @IBOutlet weak var countLabel: WKInterfaceLabel!
    @IBOutlet weak var stateLabel: WKInterfaceLabel!
    @IBOutlet weak var controlButton: WKInterfaceButton!
    
    var workoutInSession: Bool = false {
        didSet {
            controlButton.setTitle(workoutInSession ? "Stop" : "Start")
        }
    }
    
    var count = 0 {
        didSet {
            countLabel.setText("\(count)")
        }
    }
    
    var state = State.up {
        didSet {
            stateLabel.setText(state.rawValue)
        }
    }
    
    var workoutManager: WorkoutManager?
    
    override init() {
        super.init()
        connectivitySession?.delegate = self
        connectivitySession?.activate()
    }
    
    override func awake(withContext context: Any?) {
        self.count = 0
        self.state = .up
        
        guard let calibrationData = UserDefaults.standard.data(forKey: "calibration") else { return }
        guard let calibration = try? PropertyListDecoder().decode(Calibration.self, from: calibrationData) else { return }
        self.workoutManager = WorkoutManager(withDetector: RepDetector(withCalibration: calibration))
        self.workoutManager?.delegate = self
    }
    
    @IBAction func start() {
        if workoutInSession {
            self.workoutManager?.stopWorkout()
            self.workoutInSession = false
        } else {
            WKInterfaceDevice().play(.start)
            workoutManager?.startWorkout()
            self.workoutInSession = true
        }
    }
    
    func workoutStateUpdated(_ manager: WorkoutManager, repNumber: Int, state: State, workoutComplete: Bool) {
        print("\(repNumber), \(state.rawValue), \(workoutComplete)")
        DispatchQueue.main.async {
            if workoutComplete {
                self.workoutManager?.stopWorkout()
                self.controlButton.setEnabled(true)
            } else {
                WKInterfaceDevice().play(.click)
            }
            
            self.count = repNumber
            self.state = state
        }
    }
    
    func workoutEnded(_ manager: WorkoutManager, sessionData: [MotionData]?) {
        // Encode the session data as JSON
        
        try? self.save(jsonData: sessionData, toFileNamed: "\(self.WORKOUT_TYPE.rawValue)-\(Date().datetime)")
    }
}

extension WorkoutController: WCSessionFileTransferDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("Session Activated")
        } else if activationState == .inactive {
            print("Session Inactive")
        } else {
            print("Session Deactivated")
        }
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        if let error = error {
            // If there was an error in file transfer, save the file to UserDefaults so we can transfer it later
            print(error.localizedDescription)
            saveLocalFile(from: fileTransfer)
        } else {
            print("File transferred successfully")
        }
    }
}
