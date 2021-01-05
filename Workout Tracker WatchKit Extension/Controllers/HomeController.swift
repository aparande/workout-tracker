//
//  HomeController.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/31/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation
import WatchKit

/**
 Interface controller for the home screen
 */
class HomeController: WKInterfaceController {
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        switch segueIdentifier {
        case "go_to_calibration":
            return 5
        default:
            return nil
        }
    }
}
