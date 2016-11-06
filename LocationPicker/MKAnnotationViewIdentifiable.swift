//
//  MKAnnotationViewIdentifiable.swift
//  LocationPicker
//
//  Created by Brian Semiglia on 11/3/16.
//  Copyright © 2016 Brian Semiglia. All rights reserved.
//

import Foundation
import MapKit

extension MKAnnotationView {
  
  final class Identifiable: MKAnnotationView {
    var backing: Any
    var coordinate: CLLocationCoordinate2D
    init (
      backing: Any,
      coordinate: CLLocationCoordinate2D,
      annotation: MKAnnotation?,
      reuseIdentifier: String?
      ) {
      self.backing = backing
      self.coordinate = coordinate
      super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
  
}

extension MKMapView {
  
  func render(annotation input: MKPointAnnotation.Identifiable) {
    render(annotations: [input])
  }
  
  func render(annotations input: [MKPointAnnotation.Identifiable]) {
    if let before = self.allButUsersLocation as? [MKPointAnnotation.Identifiable] {
      self.removeAnnotations(before.itemsNotFoundIn(input))
      self.addAnnotations(input.itemsNotFoundIn(before))
      DispatchQueue.main.async { // Dispatch async to allow map to update before calling -viewForAnnotation.
        self.allButUsersLocation
          .flatMap{ $0 as? MKPointAnnotation.Identifiable }
          .forEach { x in
            if let current = self.view(for: x) {
              if x.isSelected {
                current.superview?.bringSubview(toFront: current)
              }
            }
        }
      }
    }
  }
  
  var allButUsersLocation: [MKAnnotation] { return
    annotations.filter { !$0.isKind(of: MKUserLocation.self) }
  }
  
}
