/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This class manages the CoreMotion interactions and 
         provides a delegate to indicate changes in data.
 */

import Foundation
import CoreMotion
import WatchKit
import os.log

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    var datetime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy-HH:mm:ss"
        return formatter.string(from: self)
    }
}

protocol MotionManagerDelegate {
    func didLog(_ motion: MotionData)
}

class MotionManager {
    // MARK: Properties
    
    let motionManager: DeviceMotionManager
    let queue = OperationQueue()
    let wristLocationIsLeft = WKInterfaceDevice.current().wristLocation == .left

    // MARK: Application Specific Constants
    
    // The app is using 50hz data and the buffer is going to hold 1s worth of data.
    let sampleInterval = 1.0 / 50
        
    var delegate: MotionManagerDelegate?

    // MARK: Initialization
    init() {
        // Serial queue for sample handling and calculations.
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
        
        #if targetEnvironment(simulator)
        motionManager = MockCMMotionManager()
        #else
        motionManager = CMMotionManager()
        #endif
    }

    // MARK: Motion Manager
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

            if deviceMotion != nil {
                self.log(deviceMotion!)
            }
        }
        #endif
        
    }

    func stopUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
        }
    }

    // MARK: Motion Processing
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
