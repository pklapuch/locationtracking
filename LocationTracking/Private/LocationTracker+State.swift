//
//  LocationTracker+State.swift
//  LocaationTracking
//
//  Created by Pawel Klapuch on 13/09/2020.
//

import Foundation

extension LocationTracker {

    internal enum ManagerState {
        
        case idle
        case waitingForAuthorization
        case tracking
    }

    internal enum RequestAuthorization {

        case whenInUse
        case always
    }

    internal enum AuthorizationType   {
        
        case unknown
        case denied
        case whenInUse
        case always
    }

    internal struct Configuration {
    
        let isServiceEnabled: Bool
        let shouldTrack: Bool
        let allowBackgroundUpdates: Bool
        
        init(isServiceEnabled: Bool, shouldTrack: Bool, allowBackgroundUpdates: Bool) {
            
            self.isServiceEnabled = isServiceEnabled
            self.shouldTrack = shouldTrack
            self.allowBackgroundUpdates = allowBackgroundUpdates
        }
    }

}
