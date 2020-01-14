/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This class manages the HealthKit interactions and provides a delegate 
         to indicate changes in data.
 */

import Foundation
import HealthKit

protocol WorkoutManagerDelegate: class {
    func didUpdateMotion(_ manager: WorkoutManager, repNumber: Int, state: State, workoutComplete: Bool)
}

class WorkoutManager {
    // MARK: Properties
    let motionManager = MotionManager()
    let healthStore = HKHealthStore()

    weak var delegate: WorkoutManagerDelegate?
    var session: HKWorkoutSession?
    
    let totalReps: Int
    var repNumber: Int
    var state: State
    
    var repLog:[(Int64, State)] = []

    // MARK: Initialization
    
    init(withReps repCount: Int) {
        //motionManager.delegate = self
        
        self.totalReps = repCount
        self.repNumber = 0
        self.state = .up
    }

    // MARK: WorkoutManager
    
    func startWorkout() {
        // If we have already started the workout, then do nothing.
        if (session != nil) {
            return
        }
        
        self.repNumber = 0
        self.state = .up

        // Configure the workout session.
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .other
        workoutConfiguration.locationType = .unknown

        do {
            session = try HKWorkoutSession(configuration: workoutConfiguration)
        } catch {
            fatalError("Unable to create the workout session!")
        }

        // Start the workout session and device motion updates.
        healthStore.start(session!)
        motionManager.startUpdates()
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
            switch self.state {
            case .up:
                if self.repNumber == self.totalReps {
                    self.stopWorkout()
                    self.delegate?.didUpdateMotion(self, repNumber: self.repNumber, state: self.state, workoutComplete: true)
                    timer.invalidate()
                    return
                }
                
                self.repNumber += 1
                self.state = .down
                self.delegate?.didUpdateMotion(self, repNumber: self.repNumber, state: self.state, workoutComplete: false)
            case .down:
                self.state = .up
                self.delegate?.didUpdateMotion(self, repNumber: self.repNumber, state: self.state, workoutComplete: false)
            }
            self.repLog.append((Date().millisecondsSince1970, self.state))
        }
    }

    func stopWorkout() {
        // If we have already stopped the workout, then do nothing.
        if (session == nil) {
            return
        }

        // Stop the device motion updates and workout session.
        motionManager.stopUpdates()
        healthStore.end(session!)

        // Clear the workout session.
        session = nil
        
        for rep in repLog {
            print(rep)
        }
    }
}
