//
//  LocationTracking.swift
//  LocationTracking
//
//  Created by Pawel Klapuch on 9/25/20.
//

import Foundation
import CoreLocation

public class LocationTracker: NSObject {
    
    public typealias TrackingAuthorizedBlock = (Bool) -> Void
    
    private var queue = DispatchQueue(label: "location")
    private var observers = [ObjectIdentifier : LocationTrackingObserver]()
    private var manager: CLLocationManager?
    
    private let preferredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBestForNavigation
    private let preferredAuthrizationType = RequestAuthorization.whenInUse
    
    /** Initial state = .unknown ( request for authorization was not processed yet */
    private var authorizationType = AuthorizationType.unknown
    private var didRequestAuthorization = false
    
    private var processing = false
    private var hasQueuedUpdate = false
    private var state: ManagerState = .idle
    private var dataProvider: LocationTrackerDataProvider<LocationTracker>?
    
    public override init() {
    
        super.init()
        configure()
    }
    
    public func isTrackingAuthorized(block:@escaping TrackingAuthorizedBlock) {
        
        queue.async { [weak self] in
            guard let self = self else { return }
            block(self.authorizationType != .denied)
        }
    }
    
    public func isTrackingPossible(block:@escaping TrackingAuthorizedBlock) {
        
        // NOTE: If authorizationType == .denied => not possible
        // NOTE: If authorizationType == .unknown -> we can assume that it's possible to track location
        // In worst case 'request authorization' will return 'denied' state which will be handled
        
        DispatchQueue.main.async { [weak self] in
            let state = CLLocationManager.locationServicesEnabled()
            self?.queue.async {
                block(state)
            }
        }
    }
    
    private func configure() {
        
        manager = createLocationManager()
        dataProvider = createDataProvider(manager)
        
        if (!self.didRequestAuthorization) {
            self.requestAuthorization(.whenInUse)
        }
    }
    
    private func updateState() {
        
        observers = observers.filter({ $0.value.delegate != nil })
        
        let bgUpdates = observers.first(where: { $0.value.needsBgUpdates == true }) != nil
        let shouldTrack = observers.count > 0
        
        DispatchQueue.main.async { [weak self] in
            
            let enabled = CLLocationManager.locationServicesEnabled()
            let config = Configuration(isServiceEnabled: enabled,
                                       shouldTrack: shouldTrack,
                                       allowBackgroundUpdates: bgUpdates)
            
            self?.queue.async {
                self?.didLoadConfiguration(config)
            }
        }
    }
    
    private func didLoadConfiguration(_ config: Configuration) {
        
        // NOTE: Designed to execute on self.queue
        
        guard processing == false else {
            
            hasQueuedUpdate = true
            return
        }
        processing = true
        
        switch state {
        
            case .idle: onIdle(config: config)
            case .waitingForAuthorization: resume(shouldProcessQueuedState: true)
            case .tracking: onTracking(config: config)
        }
    }
    
    private func onIdle(config: Configuration) {
        
        // NOTE: Designed to execute on self.queue
        
        guard config.shouldTrack else {
            
            resume(shouldProcessQueuedState: true)
            return
        }
        
        guard config.isServiceEnabled else {
            
            // ERROR - notify
            resume(shouldProcessQueuedState: true)
            return
        }
        
        switch authorizationType {
        
        case .unknown:
            
            guard !didRequestAuthorization else {
                resume(shouldProcessQueuedState: true)
                return
            }
            
            requestAuthorization(preferredAuthrizationType)
            resume(shouldProcessQueuedState: false)
            
        case .denied:
            
            // ERROR - notify - .unauthorized
            resume(shouldProcessQueuedState: true)
        
        case .whenInUse, .always: ()
            
            state = .tracking
            dataProvider?.startTrackingLocation()
            resume(shouldProcessQueuedState: true)
        }
    }
    
    private func onTracking(config: Configuration) {
       
        if !config.shouldTrack {
            
            dataProvider?.stopTrackingLocation()
            state = .idle
            resume(shouldProcessQueuedState: true)
            
        } else {
            
            manager?.allowsBackgroundLocationUpdates = config.allowBackgroundUpdates
            resume(shouldProcessQueuedState: true)
        }
    }
    
    private func resume(shouldProcessQueuedState: Bool) {
        
        processing = false
        guard hasQueuedUpdate && shouldProcessQueuedState else { return }
        hasQueuedUpdate = false
        updateState()
    }
    
    private func requestAuthorization(_ authorization: RequestAuthorization) {
        
        didRequestAuthorization = true
        state = .waitingForAuthorization
        
        DispatchQueue.main.async {
            
            switch authorization {
            case .always:
                self.manager?.requestAlwaysAuthorization()
            case .whenInUse:
                self.manager?.requestWhenInUseAuthorization()
            }
        }
    }

    fileprivate func createLocationManager() -> CLLocationManager {
        
        let manager = CLLocationManager()
        
        manager.desiredAccuracy = preferredAccuracy
        manager.allowsBackgroundLocationUpdates = false
        manager.pausesLocationUpdatesAutomatically = false
        manager.showsBackgroundLocationIndicator = false
        
        return manager
    }
    
    fileprivate func createDataProvider(_ manager: CLLocationManager?) -> LocationTrackerDataProvider<LocationTracker>? {
        
        guard let manager = manager else { return nil }
        return LocationTrackerDataProvider(manager: manager, dataDelegate: self, queue: queue)
    }
}

extension LocationTracker: LocationTrackingProtocol {
    
    public func startTracking(_ observer: LocationTrackingDataProtocol, needsBgUpdates: Bool) {
        
        let observerID = ObjectIdentifier(observer)
        
        queue.async {
            
            guard self.observers.first(where: { $0.key == observerID }) == nil else { return }
            self.observers[observerID] = LocationTrackingObserver(delegate: observer, needsBgUpdates: needsBgUpdates)
            self.updateState()
        }
    }
    
    public func stopTracking(_ observer: LocationTrackingDataProtocol) {
        
        let observerID = ObjectIdentifier(observer)
        
        queue.async {
            self.observers = self.observers.filter { $0.key != observerID && $0.value.delegate != nil }
            self.updateState()
        }
    }
}

extension LocationTracker: LocationTrackerInnerDataProtocol {
    
    // NOTE:
    // Callbackes designed to execute on self.queue
    
    func location(manager: CLLocationManager, didUpdateLocation location: CLLocation) {
        
        observers.forEach { $0.value.delegate?.locationTracking(self, didUpdateLocation: location) }
    }
    
    func location(manager: CLLocationManager, error: Error) {
        
        observers.forEach { $0.value.delegate?.locationTracking(self, didFailWithError: error) }
    }
    
    func location(manager: CLLocationManager, didChangeAuthorizationTo authorization: CLAuthorizationStatus) {
     
        state = .idle // why ?
        authorizationType = authorization.internalType
        updateState()
        
        // TODO: not really needed atm
        //notifyAuthorizationStateChanged()
    }
}
