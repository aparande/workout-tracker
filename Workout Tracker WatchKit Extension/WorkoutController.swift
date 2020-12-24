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

class WorkoutController: WKInterfaceController, WorkoutManagerDelegate, WCSessionDelegate {
    // MARK: Properties
    private let connectivitySession = WCSession.isSupported() ? WCSession.default : nil

    @IBOutlet var countLabel: WKInterfaceLabel!
    @IBOutlet var stateLabel: WKInterfaceLabel!
    @IBOutlet var controlButton: WKInterfaceButton!
    
    var workoutManager: WorkoutManager!
    
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
    
    // MARK: Initialization
    override init() {
        super.init()
        connectivitySession?.delegate = self
        connectivitySession?.activate()
    }
    
    override func awake(withContext context: Any?) {
        self.workoutManager = WorkoutManager(withReps: context! as! Int)
        self.workoutManager.delegate = self
        
        self.count = 0
        self.state = .up
    }
    
    // MARK: Interface Bindings
    
    @IBAction func start() {
        controlButton.setEnabled(false)
        WKInterfaceDevice().play(.start)
        workoutManager.startWorkout()
    }

    // MARK: WorkoutManagerDelegate
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
                    
        let sessionName = UUID().uuidString
        let filePath = paths[0].appendingPathComponent("\(sessionName).json")
        
        do {
            try sessionData.write(to: filePath)
        } catch {
            print(error.localizedDescription)
            return
        }
        
        connectivitySession?.transferFile(filePath, metadata: nil)
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        if let error = error {
            // If there was an error in file transfer, save the file to UserDefaults so we can transfer it later
            print(error.localizedDescription)
            
            let sessionName = fileTransfer.file.fileURL.lastPathComponent
            var sessions = (UserDefaults.standard.array(forKey: "sessions") as? [String]) ?? []
            sessions.append(sessionName)
            UserDefaults.standard.set(sessions, forKey: "sessions")
        } else {
            print("File transferred successfully")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("Session Activated")
        } else if activationState == .inactive {
            print("Session Inactive")
        } else {
            print("Session Deactivated")
        }
    }
}

enum State:String {
    case up = "Up", down = "Down"
}
