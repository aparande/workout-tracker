/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This class is responsible for managing interactions with the interface.
 */

import WatchKit
import Foundation
import Dispatch

class WorkoutController: WKInterfaceController, WorkoutManagerDelegate {
    // MARK: Properties

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
    func didUpdateMotion(_ manager: WorkoutManager, repNumber: Int, state: State, workoutComplete: Bool) {
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
}

enum State:String {
    case up = "Up", down = "Down"
}
