//
//  LocationTrackingDataProtocol.swift
//  LocaationTracking
//
//  Created by Pawel Klapuch on 13/09/2020.
//

import Foundation
import CoreLocation

public protocol LocationTrackingDataProtocol: class {
    
    func locationTracking(_ tracker: LocationTrackingProtocol, didUpdateLocation location: CLLocation)
    func locationTracking(_ tracker: LocationTrackingProtocol, didFailWithError error: Swift.Error) 
}
