//
//  LocationTrackingError.swift
//  LocaationTracking
//
//  Created by Pawel Klapuch on 13/09/2020.
//

import Foundation

public enum LocationTrackingError: CustomNSError {
    
    case unauthorized
    case unsupported
    case disabled
}

