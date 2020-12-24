//
//  ExtensionDelegate.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 1/14/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    private let connectivitySession = WCSession.isSupported() ? WCSession.default : nil
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        let sessions = (UserDefaults.standard.array(forKey: "sessions") as? [String]) ?? []
        print("Found \(sessions.count) unsaved files")
        for sess in sessions {
            print(sess)
        }
        
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
            for session in (UserDefaults.standard.array(forKey: "sessions") as? [String]) ?? [] {
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                            
                let filePath = paths[0].appendingPathComponent("\(session).json")
                                
                connectivitySession?.transferFile(filePath, metadata: nil)
            }
            UserDefaults.standard.set([], forKey: "sessions")
        } else if activationState == .inactive {
            print("Session Inactive")
        } else {
            print("Session Deactivated")
        }
    }

}
