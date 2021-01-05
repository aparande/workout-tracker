//
//  WCSessionFileTransferDelegate.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/24/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation
import WatchConnectivity

/**
 Objects conforming to this protocol must specifically implement the file transfer related methods of the WCSessionDelegate
 */
protocol WCSessionFileTransferDelegate: WCSessionDelegate {
    var connectivitySession: WCSession? { get }
    
    func saveLocalFile(from fileTransfer: WCSessionFileTransfer)
    func transferLocalFiles()
    
    func save<T>(jsonData: T, toFileNamed name: String) throws where T : Encodable
}

/**
 Default implementations of WCSessionFileTransferDelegate
 */
extension WCSessionFileTransferDelegate {
    var connectivitySession: WCSession? { return WCSession.isSupported() ? WCSession.default : nil }
    
    /**
     Save the file url to UserDefaults
     */
    func saveLocalFile(from fileTransfer: WCSessionFileTransfer) {
        let sessionName = fileTransfer.file.fileURL.lastPathComponent
        var sessions = (UserDefaults.standard.array(forKey: "sessions") as? [String]) ?? []
        sessions.append(sessionName)
        UserDefaults.standard.set(sessions, forKey: "sessions")
    }
    
    /**
     Transfer files in UserDefaults via WatchConnectivity
     */
    func transferLocalFiles() {
        for session in (UserDefaults.standard.array(forKey: "sessions") as? [String]) ?? [] {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                        
            let filePath = paths[0].appendingPathComponent("\(session).json")
                            
            connectivitySession?.transferFile(filePath, metadata: nil)
        }
        UserDefaults.standard.set([], forKey: "sessions")
    }
    
    /**
     Save JSON to a file and attempt to transfer it via watch connectivity
     */
    func save<T>(jsonData: T, toFileNamed name: String) throws where T : Encodable {
        let encoder = JSONEncoder()
        let data = try encoder.encode(jsonData)
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                            
        let filePath = paths[0].appendingPathComponent("\(name).json")
        
        do {
            try data.write(to: filePath)
        } catch {
            print(error.localizedDescription)
            return
        }
        
        connectivitySession?.transferFile(filePath, metadata: nil)
    }
}
