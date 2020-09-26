//
//  CLAuthorizationStatus+Model.swift
//  LocaationTracking
//
//  Created by Pawel Klapuch on 13/09/2020.
//

import Foundation
import CoreLocation

extension CLAuthorizationStatus {

    internal var internalType: LocationTracker.AuthorizationType {
        switch self {
        case .notDetermined: return .unknown
        case .authorizedWhenInUse: return .whenInUse
        case .authorizedAlways: return .always
        default: return .denied
        }
    }
}
