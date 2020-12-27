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

struct MotionData: Codable {
    let timestamp: Int64
    var state: String? = nil
    
    let gravityX: Double
    let gravityY: Double
    let gravityZ: Double
    
    let accelX: Double
    let accelY: Double
    let accelZ: Double
    
    let rotX: Double
    let rotY: Double
    let rotZ: Double
    
    let roll: Double
    let pitch: Double
    let yaw: Double
}

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
    
    let motionManager = CMMotionManager()
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
        motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            if error != nil {
                print("Encountered error: \(error!)")
            }

            if deviceMotion != nil {
                self.log(deviceMotion!)
            }
        }
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
