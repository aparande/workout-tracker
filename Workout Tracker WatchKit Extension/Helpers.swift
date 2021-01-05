//
//  Helpers.swift
//  Workout Tracker WatchKit Extension
//
//  Created by Anmol Parande on 12/30/20.
//  Copyright © 2020 Anmol Parande. All rights reserved.
//

import Foundation

extension Array where Element: Comparable {
    func argmax() -> Index? {
        // https://gist.github.com/bdsaglam/b41294540756768f26dca70d058f8e1e
        return indices.max(by: { self[$0] < self[$1] })
    }
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
