/*
Adapted from https://developer.apple.com/library/archive/samplecode/SwingWatch/Listings/SwingWatch_WatchKit_Extension_MotionManager_swift.html#//apple_ref/doc/uid/TP40017286-SwingWatch_WatchKit_Extension_MotionManager_swift-DontLinkElementID_9
 
Class to grab motion data from the watch
 */

import Foundation
import CoreMotion
import WatchKit
import os.log

protocol MotionManagerDelegate {
    func didLog(_ motion: MotionData)
}

class MotionManager {
    let motionManager: DeviceMotionManager
    let queue = OperationQueue()
    let wristLocationIsLeft = WKInterfaceDevice.current().wristLocation == .left
    
    // The app is using 50hz data
    let sampleInterval = 1.0 / 50
        
    var delegate: MotionManagerDelegate?

    init() {
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
        
        #if targetEnvironment(simulator)
        motionManager = MockCMMotionManager()
        #else
        motionManager = CMMotionManager()
        #endif
    }

    /**
     Start collecting motion data
     */
    func startUpdates() {
        if !motionManager.isDeviceMotionAvailable {
            print("Device Motion is not available.")
            return
        }
        
        os_log("Start Updates");

        motionManager.deviceMotionUpdateInterval = sampleInterval
        
        // Start writing motion data to the processing buffer
        #if targetEnvironment(simulator)
        motionManager.startMockedUpdates { (data) in
            guard let data = data else { return }
            self.delegate?.didLog(data)
        }
        #else
        motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            if error != nil {
                print("Encountered error: \(error!)")
            }

            if let motion = deviceMotion {
                self.log(motion)
            }
        }
        #endif
        
    }

    /**
     Stop collecting motion data
     */
    func stopUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
        }
    }

    /**
     Log motion data
     */
    func log(_ deviceMotion: CMDeviceMotion) {
        let timestamp = Date().millisecondsSince1970
        
        let data = MotionData(timestamp: timestamp,
                              gravityX: deviceMotion.gravity.x,
                              gravityY: deviceMotion.gravity.y,
                              gravityZ: deviceMotion.gravity.z,
                              accelX: deviceMotion.userAcceleration.x,
                              accelY: deviceMotion.userAcceleration.y,
                              accelZ: deviceMotion.userAcceleration.z,
                              rotX: deviceMotion.rotationRate.x,
                              rotY: deviceMotion.rotationRate.y,
                              rotZ: deviceMotion.rotationRate.z,
                              roll: deviceMotion.attitude.roll,
                              pitch: deviceMotion.attitude.pitch,
                              yaw: deviceMotion.attitude.yaw)
        
        delegate?.didLog(data)
    }
}
