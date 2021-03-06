//
//  ExtensionDelegate.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 1/14/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionFileTransferDelegate {
    func applicationDidFinishLaunching() {
        // Check if there are any sessions that haven't been transferred
        let sessions = (UserDefaults.standard.array(forKey: "sessions") as? [String]) ?? []
        print("Found \(sessions.count) unsaved files")
        
        connectivitySession?.delegate = self
        connectivitySession?.activate()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            task.setTaskCompletedWithSnapshot(false)
        }
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            // Save the file to the watch for transfer later if the file transfer fails
            saveLocalFile(from: fileTransfer)
        } else {
            print("File transferred successfully")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            // Transfer local files upon session activation
            transferLocalFiles()
        } else if activationState == .inactive {
            print("Session Inactive")
        } else {
            print("Session Deactivated")
        }
    }
}
