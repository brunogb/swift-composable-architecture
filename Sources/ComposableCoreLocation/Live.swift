import Combine
import ComposableArchitecture
import CoreLocation

extension LocationManagerClient {

  /// The live implementation of the `LocationManagerClient` interface. This implementation is
  /// capable of creating real `CLLocationManager` instances, listening to its delegate methods,
  /// and invoking its methods. You will typically use this when building for the simulator
  /// or device:
  ///
  ///     let store = Store(
  ///       initialState: AppState(),
  ///       reducer: appReducer,
  ///       environment: AppEnvironment(
  ///         locationManager: LocationManagerClient.live
  ///       )
  ///     )
  ///
  public static let live: LocationManagerClient = { () -> LocationManagerClient in
    var client = LocationManagerClient()

    client.authorizationStatus = CLLocationManager.authorizationStatus

    client.create = { id in
      Effect.run { callback in
        let manager = CLLocationManager()
        var delegate = LocationManagerDelegate()
        delegate.didChangeAuthorization =  {
          callback.send(.didChangeAuthorization($0))
        }
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
        delegate.didDetermineStateForRegion = { state, region in
          callback.send(.didDetermineState(state, region: Region(rawValue: region)))
        }
        #endif
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
        delegate.didEnterRegion = { region in
          callback.send(.didEnterRegion(Region(rawValue: region)))
        }
        #endif
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
        delegate.didExitRegion = { region in
          callback.send(.didExitRegion(Region(rawValue: region)))
        }
        #endif
        #if os(iOS) || targetEnvironment(macCatalyst)
        delegate.didFailRangingForConstraintWithError = { constraint, error in
          callback.send(.didFailRanging(beaconConstraint: constraint, error: Error()))
        }
        #endif
        delegate.didFailWithError = { _ in
          callback.send(.didFailWithError(Error()))
        }
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
        delegate.didFinishDeferredUpdatesWithError = { error in
          callback.send(.didFinishDeferredUpdatesWithError(Error()))
        }
        #endif
        #if os(iOS) || targetEnvironment(macCatalyst)
        delegate.didPauseLocationUpdates = {
          callback.send(.didPauseLocationUpdates)
        }
        #endif
        #if os(iOS) || targetEnvironment(macCatalyst)
        delegate.didRangeBeaconsSatisfyingConstraint = { beacons, constraint in
          callback.send(
            .didRange(beacons: beacons.map(Beacon.init(rawValue:)), beaconConstraint: constraint)
          )
        }
        #endif
        #if os(iOS) || targetEnvironment(macCatalyst)
        delegate.didResumeLocationUpdates = {
          callback.send(.didResumeLocationUpdates)
        }
        #endif
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
        delegate.didStartMonitoringForRegion = { region in
          callback.send(.didStartMonitoring(region: Region(rawValue: region)))
        }
        #endif
        #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
        delegate.didUpdateHeading = { heading in
          callback.send(.didUpdateHeading(newHeading: Heading(rawValue: heading)))
        }
        #endif
        #if os(macOS)
        delegate.didUpdateToLocationFromLocation = { newLocation, oldLocation in
          callback.send(
            .didUpdateTo(
              newLocation: Location(rawValue: newLocation),
              oldLocation: Location(rawValue: oldLocation)
            )
          )
        }
        #endif
        delegate.didUpdateLocations = {
          callback.send(.didUpdateLocations($0.map(Location.init(rawValue:))))
        }
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
        delegate.monitoringDidFailForRegionWithError = { region, error in
          callback.send(.monitoringDidFail(region: region.map(Region.init(rawValue:)), error: Error()))
        }
        #endif
        #if os(iOS) || targetEnvironment(macCatalyst)
        delegate.didVisit = { visit in
          callback.send(.didVisit(Visit(visit: visit)))
        }
        #endif
        manager.delegate = delegate

        dependencies[id] = Dependencies(
          locationManager: manager,
          locationManagerDelegate: delegate
        )

        return AnyCancellable {
          dependencies[id] = nil
        }
      }
    }

    client.destroy = { id in
      .fireAndForget {
        dependencies[id] = nil
      }
    }

    client.locationServicesEnabled = CLLocationManager.locationServicesEnabled

    client.requestLocation = { id in
      .fireAndForget { dependencies[id]?.locationManager.requestLocation() }
    }

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    client.requestAlwaysAuthorization = { id in
      .fireAndForget { dependencies[id]?.locationManager.requestAlwaysAuthorization() }
    }
    #endif

    #if os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
    client.requestWhenInUseAuthorization = { id in
      .fireAndForget { dependencies[id]?.locationManager.requestWhenInUseAuthorization() }
    }
    #endif

    #if os(iOS) || targetEnvironment(macCatalyst)
    client.startMonitoringVisits = { id in
      .fireAndForget { dependencies[id]?.locationManager.startMonitoringVisits() }
    }
    #endif

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    client.startUpdatingLocation = { id in
      .fireAndForget { dependencies[id]?.locationManager.startUpdatingLocation() }
    }
    #endif

    #if os(iOS) || targetEnvironment(macCatalyst)
    client.stopMonitoringVisits = { id in
      .fireAndForget { dependencies[id]?.locationManager.stopMonitoringVisits() }
    }
    #endif

    client.stopUpdatingLocation = { id in
      .fireAndForget { dependencies[id]?.locationManager.stopUpdatingLocation() }
    }

    client.update = { id, properties in
      .fireAndForget {
        guard let manager = dependencies[id]?.locationManager else { return }

        #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
        if let activityType = properties.activityType {
          manager.activityType = activityType
        }
        if let allowsBackgroundLocationUpdates = properties.allowsBackgroundLocationUpdates {
          manager.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates
        }
        #endif
        #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
        if let desiredAccuracy = properties.desiredAccuracy {
          manager.desiredAccuracy = desiredAccuracy
        }
        if let distanceFilter = properties.distanceFilter {
          manager.distanceFilter = distanceFilter
        }
        #endif
        #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
        if let headingFilter = properties.headingFilter {
          manager.headingFilter = headingFilter
        }
        if let headingOrientation = properties.headingOrientation {
          manager.headingOrientation = headingOrientation
        }
        #endif
        #if os(iOS) || targetEnvironment(macCatalyst)
        if let pausesLocationUpdatesAutomatically = properties.pausesLocationUpdatesAutomatically {
          manager.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically
        }
        if let showsBackgroundLocationIndicator = properties.showsBackgroundLocationIndicator {
          manager.showsBackgroundLocationIndicator = showsBackgroundLocationIndicator
        }
        #endif
      }
    }

    return client
  }()
}

private struct Dependencies {
  let locationManager: CLLocationManager
  let locationManagerDelegate: LocationManagerDelegate
}

private var dependencies: [AnyHashable: Dependencies] = [:]

private class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
  var didChangeAuthorization: (CLAuthorizationStatus) -> Void = { _ in fatalError() }
  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
  var didDetermineStateForRegion: (CLRegionState, CLRegion) -> Void = { _, _ in fatalError() }
  #endif
  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
  var didEnterRegion: (CLRegion) -> Void = { _ in fatalError() }
  #endif
  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
  var didExitRegion: (CLRegion) -> Void = { _ in fatalError() }
  #endif
  #if os(iOS) || targetEnvironment(macCatalyst)
  var didFailRangingForConstraintWithError: (CLBeaconIdentityConstraint, Error) -> Void = { _, _ in fatalError() }
  #endif
  var didFailWithError: (Error) -> Void = { _ in fatalError() }
  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
  var didFinishDeferredUpdatesWithError: (Error?) -> Void = { _ in fatalError() }
  #endif
  #if os(iOS) || targetEnvironment(macCatalyst)
  var didPauseLocationUpdates: () -> Void = { fatalError() }
  #endif
  #if os(iOS) || targetEnvironment(macCatalyst)
  var didRangeBeaconsSatisfyingConstraint: ([CLBeacon], CLBeaconIdentityConstraint) -> Void = { _, _ in fatalError() }
  #endif
  #if os(iOS) || targetEnvironment(macCatalyst)
  var didResumeLocationUpdates: () -> Void = { fatalError() }
  #endif
  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
  var didStartMonitoringForRegion: (CLRegion) -> Void = { _ in fatalError() }
  #endif
  #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
  var didUpdateHeading: (CLHeading) -> Void = { _ in fatalError() }
  #endif
  var didUpdateLocations: ([CLLocation]) -> Void = { _ in fatalError() }
  #if os(macOS)
  var didUpdateToLocationFromLocation: (CLLocation, CLLocation) -> Void = { _, _ in fatalError() }
  #endif
  #if os(iOS) || targetEnvironment(macCatalyst)
  var didVisit: (CLVisit) -> Void = { _ in fatalError() }
  #endif
  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
  var monitoringDidFailForRegionWithError: (CLRegion?, Error) -> Void = { _, _ in fatalError() }
  #endif

  func locationManager(
    _ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus
  ) {
    self.didChangeAuthorization(status)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    self.didFailWithError(error)
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    self.didUpdateLocations(locations)
  }

  #if os(macOS)
  func locationManager(_ manager: CLLocationManager, didUpdateTo newLocation: CLLocation, from oldLocation: CLLocation) {
    self.didUpdateToLocationFromLocation(newLocation, oldLocation)
  }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
  func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
    self.didFinishDeferredUpdatesWithError(error)
  }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
  func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
    self.didPauseLocationUpdates()
  }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
  func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
    self.didResumeLocationUpdates()
  }
  #endif

  #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    self.didUpdateHeading(newHeading)
  }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    self.didEnterRegion(region)
  }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    self.didExitRegion(region)
  }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
  func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
    self.didDetermineStateForRegion(state, region)
  }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    self.monitoringDidFailForRegionWithError(region, error)
  }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
  func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
    self.didStartMonitoringForRegion(region)
  }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
  func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
    self.didRangeBeaconsSatisfyingConstraint(beacons, beaconConstraint)
  }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
  func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
    self.didFailRangingForConstraintWithError(beaconConstraint, error)
  }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
  func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
    self.didVisit(visit)
  }
  #endif
}
