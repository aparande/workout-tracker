//
//  WorkoutController.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/24/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import WatchKit
import WatchConnectivity

enum State:String {
    case up = "Up", down = "Down"
}

enum SessionType:String {
    case counting, calibration
}

class WorkoutController: WKInterfaceController {
    let WORKOUT_TYPE: SessionType = .counting
    
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
    
    var workoutManager: WorkoutManager!
    
    override init() {
        super.init()
        connectivitySession?.delegate = self
        connectivitySession?.activate()
    }
    
    override func awake(withContext context: Any?) {
        self.count = 0
        self.state = .up
        
        self.workoutManager = WorkoutManager(withDetector: PushupDetector())
        self.workoutManager.delegate = self
    }
    
    @IBAction func start() {
        if workoutInSession {
            self.workoutManager.stopWorkout()
            self.workoutInSession = false
        } else {
            WKInterfaceDevice().play(.start)
            workoutManager.startWorkout()
            self.workoutInSession = true
        }
    }
}

extension WorkoutController: WorkoutManagerDelegate {
    func workoutStateUpdated(_ manager: WorkoutManager, repNumber: Int, state: State, workoutComplete: Bool) {
        print("\(repNumber), \(state.rawValue), \(workoutComplete)")
        DispatchQueue.main.async {
            if workoutComplete {
                self.workoutManager.stopWorkout()
                self.controlButton.setEnabled(true)
            } else {
                WKInterfaceDevice().play(.click)
            }
            
            self.count = repNumber
            self.state = state
        }
    }
    
    func workoutEnded(_ manager: WorkoutManager, sessionData: Data?) {
        guard let sessionData = sessionData else { return }
        
        // Write the workout data to documents in case it can't be transferred to the phone
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                    
        let filePath = paths[0].appendingPathComponent("\(self.WORKOUT_TYPE.rawValue)-\(Date().datetime).json")
        
        do {
            try sessionData.write(to: filePath)
        } catch {
            print(error.localizedDescription)
            return
        }
        
        connectivitySession?.transferFile(filePath, metadata: nil)
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
