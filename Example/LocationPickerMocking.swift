//
//  LocationPickerMocking.swift
//  LocationPicker
//
//  Created by Brian Semiglia on 10/5/16.
//  Copyright © 2016 Brian Semiglia. All rights reserved.
//

import CoreLocation
import MapKit

struct Stub {
  let identifier: Int
}

extension Stub: Hashable {
  public var hashValue: Int { return
    identifier
  }
  static func == (left: Stub, right: Stub) -> Bool { return
    left.identifier == right.identifier
  }
}

extension LocationPicker {
  var withMocks: LocationPicker {
    outputHandler = LocationService()
    model = .loading
    DispatchQueue.main.asyncAfter(
    deadline: DispatchTime.now() + .seconds(1)) {
      self.model = .fake
    }
    return self
  }
}

extension LocationPicker.Model {
  
  static var fake: LocationPicker.Model {
    return LocationPicker.Model(
      locations: [
        LocationPicker.Model.Location(
          isSelected: true,
          isOpeningMaps: false,
          callState: .idle,
          name: "San Francisco",
          street: "123 Street St.",
          cityStateZip: "Somerville, MA 02143",
          phoneNumber: "555-555-5555",
          hoursShippingOptionsHTML: "",
          selectedImage: nil,
          deselectedImage: nil,
          coordinate: CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194
          ),
          backing: Stub(
            identifier: 0
          )
        ),
        LocationPicker.Model.Location(
          isSelected: true,
          isOpeningMaps: false,
          callState: .idle,
          name: "New York City",
          street: "123 Street St.",
          cityStateZip: "Somerville, MA 02143",
          phoneNumber: "555-555-5555",
          hoursShippingOptionsHTML: "",
          selectedImage: nil,
          deselectedImage: nil,
          coordinate: CLLocationCoordinate2D(
            latitude: 40.7128,
            longitude: -74.0059
          ),
          backing: Stub(
            identifier: 1
          )
        ),
        LocationPicker.Model.Location(
          isSelected: true,
          isOpeningMaps: false,
          callState: .idle,
          name: "Havana",
          street: "123 Street St.",
          cityStateZip: "Somerville, MA 02143",
          phoneNumber: "555-555-5555",
          hoursShippingOptionsHTML: "",
          selectedImage: nil,
          deselectedImage: nil,
          coordinate: CLLocationCoordinate2D(
            latitude: 23.1136,
            longitude: -82.3666
          ),
          backing: Stub(
            identifier: 2
          )
        ),
        LocationPicker.Model.Location(
          isSelected: true,
          isOpeningMaps: false,
          callState: .idle,
          name: "Rio de Janeiro",
          street: "123 Street St.",
          cityStateZip: "Somerville, MA 02143",
          phoneNumber: "555-555-5555",
          hoursShippingOptionsHTML: "",
          selectedImage: nil,
          deselectedImage: nil,
          coordinate: CLLocationCoordinate2D(
            latitude: -22.9068,
            longitude: -43.1729
          ),
          backing: Stub(
            identifier: 3
          )
        ),
        LocationPicker.Model.Location(
          isSelected: true,
          isOpeningMaps: false,
          callState: .idle,
          name: "Cape Town",
          street: "123 Street St.",
          cityStateZip: "Somerville, MA 02143",
          phoneNumber: "555-555-5555",
          hoursShippingOptionsHTML: "",
          selectedImage: nil,
          deselectedImage: nil,
          coordinate: CLLocationCoordinate2D(
            latitude: -33.9249,
            longitude: 18.4241
          ),
          backing: Stub(
            identifier: 4
          )
        ),
        LocationPicker.Model.Location(
          isSelected: true,
          isOpeningMaps: false,
          callState: .idle,
          name: "Egypt",
          street: "123 Street St.",
          cityStateZip: "Somerville, MA 02143",
          phoneNumber: "555-555-5555",
          hoursShippingOptionsHTML: "",
          selectedImage: nil,
          deselectedImage: nil,
          coordinate: CLLocationCoordinate2D(
            latitude: 26.8206,
            longitude: 30.8025
          ),
          backing: Stub(
            identifier: 5
          )
        ),
        LocationPicker.Model.Location(
          isSelected: true,
          isOpeningMaps: false,
          callState: .idle,
          name: "Barcelona",
          street: "123 Street St.",
          cityStateZip: "Somerville, MA 02143",
          phoneNumber: "555-555-5555",
          hoursShippingOptionsHTML: "",
          selectedImage: nil,
          deselectedImage: nil,
          coordinate: CLLocationCoordinate2D(
            latitude: 41.3851,
            longitude: 2.1734
          ),
          backing: Stub(
            identifier: 6
          )
        ),
        LocationPicker.Model.Location(
          isSelected: true,
          isOpeningMaps: false,
          callState: .idle,
          name: "Moscow",
          street: "123 Street St.",
          cityStateZip: "Somerville, MA 02143",
          phoneNumber: "555-555-5555",
          hoursShippingOptionsHTML: "",
          selectedImage: nil,
          deselectedImage: nil,
          coordinate: CLLocationCoordinate2D(
            latitude: 55.7558,
            longitude: 37.6173
          ),
          backing: Stub(
            identifier: 7
          )
        ),
        LocationPicker.Model.Location(
          isSelected: true,
          isOpeningMaps: false,
          callState: .idle,
          name: "Amman",
          street: "123 Street St.",
          cityStateZip: "Somerville, MA 02143",
          phoneNumber: "555-555-5555",
          hoursShippingOptionsHTML: "",
          selectedImage: nil,
          deselectedImage: nil,
          coordinate: CLLocationCoordinate2D(
            latitude: 31.9454,
            longitude: 35.9284
          ),
          backing: Stub(
            identifier: 8
          )
        ),
        LocationPicker.Model.Location(
          isSelected: true,
          isOpeningMaps: false,
          callState: .idle,
          name: "Mumbai",
          street: "123 Street St.",
          cityStateZip: "Somerville, MA 02143",
          phoneNumber: "555-555-5555",
          hoursShippingOptionsHTML: "",
          selectedImage: nil,
          deselectedImage: nil,
          coordinate: CLLocationCoordinate2D(
            latitude: 19.0760,
            longitude: 72.8777
          ),
          backing: Stub(
            identifier: 9
          )
        ),
        LocationPicker.Model.Location(
          isSelected: true,
          isOpeningMaps: false,
          callState: .idle,
          name: "Bangkok",
          street: "123 Street St.",
          cityStateZip: "Somerville, MA 02143",
          phoneNumber: "555-555-5555",
          hoursShippingOptionsHTML: "",
          selectedImage: nil,
          deselectedImage: nil,
          coordinate: CLLocationCoordinate2D(
            latitude: 13.7563,
            longitude: 100.5018
          ),
          backing: Stub(
            identifier: 10
          )
        ),
        LocationPicker.Model.Location(
          isSelected: true,
          isOpeningMaps: false,
          callState: .idle,
          name: "Shanghai",
          street: "123 Street St.",
          cityStateZip: "Somerville, MA 02143",
          phoneNumber: "555-555-5555",
          hoursShippingOptionsHTML: "",
          selectedImage: nil,
          deselectedImage: nil,
          coordinate: CLLocationCoordinate2D(
            latitude: 31.2304,
            longitude: 121.4737
          ),
          backing: Stub(
            identifier: 11
          )
        ),
        LocationPicker.Model.Location(
          isSelected: true,
          isOpeningMaps: false,
          callState: .idle,
          name: "Sydney",
          street: "123 Street St.",
          cityStateZip: "Somerville, MA 02143",
          phoneNumber: "555-555-5555",
          hoursShippingOptionsHTML: "",
          selectedImage: nil,
          deselectedImage: nil,
          coordinate: CLLocationCoordinate2D(
            latitude: -33.8688,
            longitude: 151.2093
          ),
          backing: Stub(
            identifier: 12
          )
        )
      ],
      state: .presentingLocationsAll,
      shouldRender: true,
      scrollLocation: MKCoordinateRegion(),
      pickerScroll: CGPoint.zero
    )
  }
  
  static var loading: LocationPicker.Model { return
    LocationPicker.Model(
      locations: [],
      state: .awaitingLocations,
      shouldRender: true,
      scrollLocation: MKCoordinateRegion(),
      pickerScroll: CGPoint.zero
    )
  }
  
}
