//
//  LocationTrackingObserver.swift
//  LocaationTracking
//
//  Created by Pawel Klapuch on 13/09/2020.
//

import Foundation

class LocationTrackingObserver {
    
    weak var delegate: LocationTrackingDataProtocol?
    var needsBgUpdates: Bool
    
    init(delegate: LocationTrackingDataProtocol?, needsBgUpdates: Bool) {
        
        self.delegate = delegate
        self.needsBgUpdates = needsBgUpdates
    }
}
