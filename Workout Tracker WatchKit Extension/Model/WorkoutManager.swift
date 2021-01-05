/*
 A super class which manages the user's workout. If initialized with a detector, it will detect repetitions
 Based on https://developer.apple.com/library/archive/samplecode/SwingWatch/Listings/SwingWatch_WatchKit_Extension_WorkoutManager_swift.html#//apple_ref/doc/uid/TP40017286-SwingWatch_WatchKit_Extension_WorkoutManager_swift-DontLinkElementID_11
 */

import Foundation
import HealthKit

protocol WorkoutManagerDelegate: AnyObject {
    /** Delegate method called when something about the workout has been updated */
    func workoutStateUpdated(_ manager: WorkoutManager, repNumber: Int, state: State, workoutComplete: Bool)
    
    /** Called when a workout is ended */
    func workoutEnded(_ manager: WorkoutManager, sessionData: [MotionData]?)
}

class WorkoutManager: MotionManagerDelegate {
    let motionManager = MotionManager()
    let healthStore = HKHealthStore()

    weak var delegate: WorkoutManagerDelegate?
    var session: HKWorkoutSession?
    
    var repNumber: Int
    var state: State
    
    var motionData:[MotionData] = []
    
    var detector: RepDetector?
    
    init(withDetector detector: RepDetector?) {
        self.repNumber = 0
        self.state = .rest
        
        self.motionManager.delegate = self
        self.detector = detector
    }
    
    /**
     Begin the workout
     */
    func startWorkout() {
        // If we have already started the workout, then do nothing.
        if (session != nil) {
            return
        }
        
        self.repNumber = 0
        self.state = .rest

        // Configure the workout session.
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .traditionalStrengthTraining
        workoutConfiguration.locationType = .unknown

        do {
            session = try HKWorkoutSession(configuration: workoutConfiguration)
        } catch {
            fatalError("Unable to create the workout session!")
        }

        // Start the workout session and device motion updates.
        healthStore.start(session!)
        motionManager.startUpdates()
    }

    /**
     End the workout
     */
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
        
        self.delegate?.workoutEnded(self, sessionData: motionData)
    }
    
    /**
     Handle data logged by the motion manager (MotionManagerDelegate method)
     */
    func didLog(_ motion: MotionData) {
        var motion = motion
        
        // Augment the data with the current state
        motion.state = self.state.rawValue
        self.motionData.append(motion)
        
        self.process(motion)
    }
    
    /**
     Process data by running it through the detector (if applicable)
     */
    func process(_ motion: MotionData) {
        // If the detector detects a new state, potentially increment our state
        if let newState = detector?.detect(from: motion), newState != self.state {
            self.state = newState
            
            // Count only a full repetition (i.e from down to up)
            if self.state == .rest {
                self.repNumber += 1
            }
            
            // Notify the delegate the state has been updated
            delegate?.workoutStateUpdated(self, repNumber: repNumber, state: newState, workoutComplete: false)
        }
    }
}
