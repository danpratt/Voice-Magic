//
//  VMAppStoreReview.swift
//  Magic Voice Editor
//
//  Created by Daniel Pratt on 11/10/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import Foundation

struct VMAppStoreReview: RateInAppStore {
    
    // Properties
    var timesUserHasOpenedApp: Int? = UserDefaults.standard.integer(forKey: "timesUserHasOpenedApp_")
    let openTimesToCheck: Int = 5
    
    init() {
        // get rid of old doNotBugToRate key (will not be used anymore)
        // NOTE: REMOVE THIS IN FOLLOWING RELEASE
        UserDefaults.standard.removeObject(forKey: "doNotBugToRate_")
        updateTimesUserHasOpenedApp()
    }
    
    mutating func updateTimesUserHasOpenedApp() {
        if timesUserHasOpenedApp == nil || timesUserHasOpenedApp! > openTimesToCheck {
            timesUserHasOpenedApp = 1
        } else {
            timesUserHasOpenedApp = timesUserHasOpenedApp! + 1
        }
        
        setTimesUserHasOpenedApp()
    }
    
    func setTimesUserHasOpenedApp() {
        UserDefaults.standard.set(timesUserHasOpenedApp, forKey: "timesUserHasOpenedApp_")
    }
    
}
