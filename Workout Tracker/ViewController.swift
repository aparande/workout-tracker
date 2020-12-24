//
//  ViewController.swift
//  Workout Tracker
//
//  Created by Anmol Parande on 1/14/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import UIKit
import WatchConnectivity

/**
 Main view controller to display a list of workout files
 */
class ViewController: UITableViewController, WCSessionDelegate {
    private let session : WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    var files:[URL] = []
    let fileDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if let _ = session {
            
        } else {
            print("not supported")
        }
        
        // Setup a Watch Connection Session
        session?.delegate = self
        session?.activate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the files already saved
        self.files = (try? FileManager.default.contentsOfDirectory(at: fileDirectory, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)) ?? []
        for file in self.files {
            print(file.absoluteString)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let file = files.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            try? FileManager.default.removeItem(at: file)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
         cell.textLabel?.text = files[indexPath.row].lastPathComponent
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = self.files[indexPath.row]
        
        let avc = UIActivityViewController(activityItems: [file], applicationActivities: nil)
        self.present(avc, animated: true, completion: nil)
    }
    
    /**
     Delegate method of the Workout Session called when a file is received
     */
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        let fileName = file.fileURL.lastPathComponent
        let newPath = fileDirectory.appendingPathComponent(fileName)
        do {
            try FileManager.default.moveItem(at: file.fileURL, to: newPath)
            
            print("Received file \(newPath.absoluteString)")
            self.files.append(newPath)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /**
     Delegate method called when a message is received from the watch
     */
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        let sessionName = UUID().uuidString
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let directoryPath = paths[0].appendingPathComponent("\(sessionName).json")
        
        do {
            try messageData.write(to: directoryPath)
            
            files.append(directoryPath)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print(error.localizedDescription)
            let alertView = UIAlertController(title: "Error", message: "Couldnt save session", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(activationState)
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //pass
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //Pass
    }
}

