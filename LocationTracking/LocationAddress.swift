//
//  LocationAddress.swift
//  LocationTracking
//
//  Created by Pawel Klapuch on 10/1/20.
//

import Foundation
import CoreLocation

public protocol LocationAddress {
    
    var name: String? { get } // eg. Apple Inc.
    var thoroughfare: String? { get } // street name, eg. Infinite Loop
    var subThoroughfare: String? { get } // eg. 1
    var locality: String? { get } // city, eg. Cupertino
    var subLocality: String? { get } // neighborhood, common name, eg. Mission District
    var administrativeArea: String? { get } // state, eg. CA
    var subAdministrativeArea: String? { get } // county, eg. Santa Clara
    var postalCode: String? { get } // zip code, eg. 95014
    var isoCountryCode: String? { get } // eg. US
    var country: String? { get } // eg. United States
    var inlandWater: String? { get } // eg. Lake Tahoe
    var ocean: String? { get } // eg. Pacific Ocean
    var areasOfInterest: [String]? { get } // eg. Golden Gate Park
    var address: PostalAddress? { get }
    var addressPrettyFormatted: String? { get }
}
