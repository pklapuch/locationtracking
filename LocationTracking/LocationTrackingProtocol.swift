//
//  LocationTrackingProtocol.swift
//  LocaationTracking
//
//  Created by Pawel Klapuch on 13/09/2020.
//

import Foundation

public protocol LocationTrackingProtocol: class {
    
    func startTracking(_ observer: LocationTrackingDataProtocol, needsBgUpdates: Bool)
    
    func stopTracking(_ observer: LocationTrackingDataProtocol)
}
