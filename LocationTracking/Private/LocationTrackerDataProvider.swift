//
//  LocationTrackerDataProvider.swift
//  LocaationTracking
//
//  Created by Pawel Klapuch on 13/09/2020.
//

import Foundation
import CoreLocation

protocol LocationTrackerInnerDataProtocol: class {
    
    func location(manager: CLLocationManager, didUpdateLocation location: CLLocation)
    func location(manager: CLLocationManager, error: Swift.Error)
    func location(manager: CLLocationManager, didChangeAuthorizationTo authorization: CLAuthorizationStatus)
}

class LocationTrackerDataProvider<DataDelegate: LocationTrackerInnerDataProtocol>: NSObject, CLLocationManagerDelegate {
    
    private weak var manager: CLLocationManager?
    private weak var dataDelegate: DataDelegate?
    private var queue: DispatchQueue?
    
    init(manager: CLLocationManager, dataDelegate: DataDelegate, queue: DispatchQueue? = nil) {
        
        self.manager = manager
        self.dataDelegate = dataDelegate
        self.queue = queue
        super.init()
        
        manager.delegate = self
    }
    
    func startTrackingLocation() {
        
        DispatchQueue.main.async { [weak self] in
            self?.manager?.startUpdatingLocation()
        }
    }
    
    func stopTrackingLocation() {
        
        DispatchQueue.main.async { [weak self] in
            self?.manager?.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else { return }
        if let queue = queue {
            queue.async { [weak self] in
                self?.dataDelegate?.location(manager: manager, didUpdateLocation: location)
            }
        } else {
            dataDelegate?.location(manager: manager, didUpdateLocation: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        if let queue = queue {
            queue.async { [weak self] in
                self?.dataDelegate?.location(manager:manager, error: error)
            }
        } else {
            dataDelegate?.location(manager:manager, error: error)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if let queue = queue {
            queue.async { [weak self] in
                self?.dataDelegate?.location(manager: manager, didChangeAuthorizationTo: status)
            }
        } else {
            dataDelegate?.location(manager: manager, didChangeAuthorizationTo: status)
        }
        
//        queue.async {
            
//            log.debug("LocationManager: did change authorization to: \(status.stringValue)")
//            self.state = .idle
//            self.authorizationType = self.authorizationTypeFromAuthorizationStatus(status)
//            self.updateState()
//            self.notifyAuthorizationStateChanged()
//        }
    }
}
