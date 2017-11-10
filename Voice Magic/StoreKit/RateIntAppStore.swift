//
//  RateIntAppStore.swift
//  Magic Voice Editor
//
//  Created by Daniel Pratt on 11/10/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

protocol RateInAppStore {
    var timesUserHasOpenedApp : Int? { get set }
    var openTimesToCheck : Int { get }
    var shouldAskToRate : Bool { get }
}

extension RateInAppStore {
    var shouldAskToRate : Bool {
        return timesUserHasOpenedApp == openTimesToCheck
    }
}
