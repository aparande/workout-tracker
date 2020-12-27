/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This class manages the HealthKit interactions and provides a delegate 
         to indicate changes in data.
 */

import Foundation
import HealthKit

protocol WorkoutManagerDelegate: AnyObject {
    func workoutStateUpdated(_ manager: WorkoutManager, repNumber: Int, state: State, workoutComplete: Bool)
    func workoutEnded(_ manager: WorkoutManager, sessionData: Data?)
}

class WorkoutManager: MotionManagerDelegate {
    // MARK: Properties
    let motionManager = MotionManager()
    let healthStore = HKHealthStore()

    weak var delegate: WorkoutManagerDelegate?
    var session: HKWorkoutSession?
    
    var repNumber: Int
    var state: State
    
    var motionData:[MotionData] = []
    
    var detector: PushupDetector?

    // MARK: Initialization
    
    init(withDetector detector: PushupDetector?) {
        self.repNumber = 0
        self.state = .up
        
        self.motionManager.delegate = self
        self.detector = detector
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
        workoutConfiguration.activityType = .tennis // Hopefully makes accelerometer data more accurate
        workoutConfiguration.locationType = .outdoor

        do {
            session = try HKWorkoutSession(configuration: workoutConfiguration)
        } catch {
            fatalError("Unable to create the workout session!")
        }

        // Start the workout session and device motion updates.
        healthStore.start(session!)
        motionManager.startUpdates()
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
        
        // Encode the session data as JSON
        let encoder = JSONEncoder()
        do {
            let json = try encoder.encode(self.motionData)
            self.delegate?.workoutEnded(self, sessionData: json)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Motion Manager delegate called when motion data is processed from the buffer
    func didLog(_ motion: MotionData) {
        var motion = motion
        motion.state = self.state.rawValue
        self.motionData.append(motion)
        
        self.process(motion)
    }
    
    func process(_ motion: MotionData) {
        if let newState = detector?.detect(from: motion), newState != self.state {
            self.state = newState
            
            if self.state == .up {
                self.repNumber += 1
            }
            
            delegate?.workoutStateUpdated(self, repNumber: repNumber, state: newState, workoutComplete: false)
        }
    }
}
