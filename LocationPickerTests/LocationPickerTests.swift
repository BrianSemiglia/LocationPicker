//
//  LocationPickerTests.swift
//  LocationPickerTests
//
//  Created by Brian Semiglia on 9/18/16.
//  Copyright © 2016 Brian Semiglia. All rights reserved.
//

import XCTest
import CoreLocation

@testable import LocationPicker

class LocationPickerTests: XCTestCase {
  
  func testStubShouldEqual() {
    XCTAssert(Stub(identifier: 0) == Stub(identifier: 0))
  }
  
  func testStubShouldNotEqual() {
    XCTAssert(Stub(identifier: 0) != Stub(identifier: 1))
  }
  
  func testLocationShouldEqual() {
    XCTAssert(LocationPickerTests.location1 == LocationPickerTests.location1)
  }
  
  func testLocationShouldNotEqual() {
    XCTAssert(LocationPickerTests.location1 != LocationPickerTests.location2)
  }
  
  static var location1: LocationPicker.Model.Location {
    return LocationPicker.Model.Location(
      isSelected: false,
      isOpeningMaps: false,
      callState: .idle,
      name: "name",
      street: "street",
      cityStateZip: "cityStateZip",
      phoneNumber: "555-555-5555",
      hoursShippingOptionsHTML: "",
      selectedImage: UIImage(named: "pin-blue-dark")!,
      deselectedImage: UIImage(named: "pin-blue-dark")!,
      coordinate: CLLocationCoordinate2D(),
      backing: NSObject()
    )
  }
  
  static var location2: LocationPicker.Model.Location {
    return LocationPicker.Model.Location(
      isSelected: false,
      isOpeningMaps: false,
      callState: .idle,
      name: "eman",
      street: "teerts",
      cityStateZip: "piZetatSytic",
      phoneNumber: "555-555-5555",
      hoursShippingOptionsHTML: "",
      selectedImage: UIImage(named: "pin-blue-dark")!,
      deselectedImage: UIImage(named: "pin-blue-dark")!,
      coordinate: CLLocationCoordinate2D(),
      backing: NSObject()
    )
  }
}
