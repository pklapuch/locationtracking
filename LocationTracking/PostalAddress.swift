//
//  PostalAddress.swift
//  LocationTracking
//
//  Created by Pawel Klapuch on 10/1/20.
//

import Foundation

public protocol PostalAddress {
    
    // The street name in a postal address.
    var street: String { get }
    
    // The city name in a postal address.
    var city: String { get }
    
    // The state name in a postal address.
    var state: String { get }
    
    // The postal code in a postal address.
    var postalCode: String { get }
    
    // The country name in a postal address.
    var country: String { get }
    
    // The ISO country code for the country in a postal address, using the ISO 3166-1 alpha-2 standard.
    var isoCountryCode: String { get }
    
    // The subadministrative area (such as a county or other region) in a postal address.
    var subAdministrativeArea: String { get }
    
    // Additional information associated with the location, typically defined at the city or town level, in a postal address.
    var subLocality: String { get }
}
