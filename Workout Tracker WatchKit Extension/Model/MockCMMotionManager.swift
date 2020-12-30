//
//  MockCMMotionManager.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/29/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation
import CoreMotion

protocol DeviceMotionManager:AnyObject {
    var isDeviceMotionAvailable: Bool { get }
    var deviceMotionUpdateInterval: Double { get set }
    
    func startDeviceMotionUpdates(to queue: OperationQueue, withHandler handler: @escaping CMDeviceMotionHandler)
    func stopDeviceMotionUpdates()
    func startMockedUpdates(handler: @escaping (MotionData?) -> Void)
}

extension CMMotionManager: DeviceMotionManager {
    func startMockedUpdates(handler: @escaping (MotionData?) -> Void) {
        fatalError("Started mocked updates on real device!")
    }
}

class MockCMMotionManager: DeviceMotionManager {
    var isDeviceMotionAvailable = true
    var deviceMotionUpdateInterval = 1.0 / 50.0
    
    var motionData: [MotionData]
    var timer: Timer?
    
    init() {
        let dataPath = Bundle.main.path(forResource: "calibration", ofType: "json")!
        
        let data = try! Data(contentsOf: URL(fileURLWithPath: dataPath), options: .mappedIfSafe)
        motionData = try! JSONDecoder().decode([MotionData].self, from: data)
    }
    
    func startDeviceMotionUpdates(to queue: OperationQueue, withHandler handler: @escaping CMDeviceMotionHandler) {
        fatalError("Started real updates on mock device!")
    }
    
    func startMockedUpdates(handler: @escaping (MotionData?) -> Void) {
        print("Starting mocked motion updates")
        timer = Timer.scheduledTimer(withTimeInterval: deviceMotionUpdateInterval, repeats: true, block: { (timer) in
            if self.motionData.count <= 0 {
                handler(nil)
            } else {
                handler(self.motionData.removeFirst())
            }
        })
    }
    
    func stopDeviceMotionUpdates() {
        print("Stopping device motion")
        timer?.invalidate()
    }
}
