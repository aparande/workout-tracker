//
//  WCSessionFileTransferDelegate.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/24/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation
import WatchConnectivity

protocol WCSessionFileTransferDelegate: WCSessionDelegate {
    var connectivitySession: WCSession? { get }
    
    func saveLocalFile(from fileTransfer: WCSessionFileTransfer)
    func transferLocalFiles()
}

extension WCSessionFileTransferDelegate {
    var connectivitySession: WCSession? { return WCSession.isSupported() ? WCSession.default : nil }
    
    func saveLocalFile(from fileTransfer: WCSessionFileTransfer) {
        let sessionName = fileTransfer.file.fileURL.lastPathComponent
        var sessions = (UserDefaults.standard.array(forKey: "sessions") as? [String]) ?? []
        sessions.append(sessionName)
        UserDefaults.standard.set(sessions, forKey: "sessions")
    }
    
    func transferLocalFiles() {
        for session in (UserDefaults.standard.array(forKey: "sessions") as? [String]) ?? [] {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                        
            let filePath = paths[0].appendingPathComponent("\(session).json")
                            
            connectivitySession?.transferFile(filePath, metadata: nil)
        }
        UserDefaults.standard.set([], forKey: "sessions")
    }
}
