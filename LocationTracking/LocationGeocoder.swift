//
//  LocationGeocoder.swift
//  LocationTracking
//
//  Created by Pawel Klapuch on 10/1/20.
//

import Foundation
import CoreLocation
import Contacts

public class LocationGeocoder: NSObject {
    
    public typealias SuccessBlock = (LocationAddress) -> Void
    public typealias FailureBlock = (Swift.Error) -> Void
    
    enum Error: CustomNSError {
        
        case addressNotFound
    }
    
    public override init() { }
    private let geocoder = CLGeocoder()
    
    public func getAddress(at coordinate: CLLocationCoordinate2D,
                    onSuccess:@escaping SuccessBlock,
                    onFailure:@escaping FailureBlock) {
     
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            
            if let error = error {
                
                onFailure(error)
                return
            }
            
            guard let placemarks = placemarks, !placemarks.isEmpty else {
                
                onFailure(Error.addressNotFound)
                return
            }
            
            onSuccess(placemarks[0])
        }
    }
}

extension CLPlacemark: LocationAddress {
    
    public var address: PostalAddress? {
        
        return postalAddress
    }
    
    public var addressPrettyFormatted: String? {
            
       guard let postalAddress = postalAddress else { return nil }
       
       let formatter = CNPostalAddressFormatter()
       return formatter.string(from: postalAddress)
    }
}

extension CNPostalAddress: PostalAddress { }


