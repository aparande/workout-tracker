//
//  RepController.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 1/14/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import WatchKit

class RepController: WKInterfaceController {
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        switch segueIdentifier {
        case "5_reps":
            return 5
        case "10_reps":
            return 10
        case "15_reps":
            return 15
        default:
            return 0
        }
    }

}
