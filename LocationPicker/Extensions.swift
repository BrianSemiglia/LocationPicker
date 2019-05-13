//
//  Extensions.swift
//  LocationPicker
//
//  Created by Brian Semiglia on 11/3/16.
//  Copyright © 2016 Brian Semiglia. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

extension CLLocationCoordinate2D {
  init?(_ input: CGPoint) {
    if let possible = CLLocationCoordinate2D.initPossible(
      latitude: CLLocationDegrees(input.x),
      longitude: CLLocationDegrees(input.y)
      ){
      self = possible
    } else {
      return nil
    }
  }
}

extension CGPoint {
  init(_ input: CLLocationCoordinate2D) {
    self = CGPoint(
      x: CGFloat(input.latitude),
      y: CGFloat(input.longitude)
    )
  }
}

extension CLLocationCoordinate2D {
  static func initPossible(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> CLLocationCoordinate2D? {
    if
      latitude >= -90.0 &&
        latitude <= 90.0 &&
        longitude >= -180.0 &&
        longitude <= 180.0 { return
      CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    } else { return
      nil
    }
  }
}

extension CLLocationCoordinate2D {
  func pointUntil(destination: CLLocationCoordinate2D, percentage: Double) -> CLLocationCoordinate2D? { return
    CLLocationCoordinate2D.initPossible(
      latitude: self.latitude + (destination.latitude - self.latitude) * percentage,
      longitude: self.longitude + (destination.longitude - self.longitude) * percentage
    )
  }
}

extension MKPointAnnotation {
  final class Identifiable: MKPointAnnotation {
    var isSelected = false
    var backing: Any
    init (isSelected: Bool, coordinate: CLLocationCoordinate2D, title: String, backing: Any) {
      self.backing = backing
      self.isSelected = isSelected
      super.init()
      self.coordinate = coordinate
      self.title = title
    }
    override var hash: Int { return
      (title! + String(describing: coordinate)).hash
    }
    override func isEqual(_ object: Any?) -> Bool {
      if let right = object as? Identifiable { return
        coordinate == right.coordinate &&
          title == right.title
      } else { return
        false
      }
    }
  }
}

extension MKPointAnnotation.Identifiable {
  static func ==(left: Identifiable, right: Identifiable) -> Bool { return
    left.coordinate == right.coordinate &&
      left.title == right.title
  }
}

extension MKCoordinateRegion {
  static public func ==(left: MKCoordinateRegion, right: MKCoordinateRegion) -> Bool { return
    left.center == right.center &&
      left.span == right.span
  }
}

extension MKCoordinateSpan {
  static public func ==(left: MKCoordinateSpan, right: MKCoordinateSpan) -> Bool { return
    left.latitudeDelta == right.latitudeDelta &&
      left.longitudeDelta == right.longitudeDelta
  }
}

extension CLLocationCoordinate2D {
  public static func ==(left: CLLocationCoordinate2D, right: CLLocationCoordinate2D) -> Bool { return
    left.latitude == right.latitude &&
      left.longitude == right.longitude
  }
}

extension UICollectionView {
  func perform(batchUpdates: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
    performBatchUpdates(batchUpdates, completion: completion)
  }
    func possiblyScrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
    if
      let source = dataSource,
      let number = source.numberOfSections.map({ $0(self) }),
      indexPath.section < number,
      indexPath.row < source.collectionView(self, numberOfItemsInSection: indexPath.section) {
      scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
  }
}

extension MKCoordinateSpan {
  static var zoomedOut: MKCoordinateSpan { return
    MKCoordinateSpan(
        latitudeDelta: 0.00625,
        longitudeDelta: 0.00625
    )
  }
}

extension CLLocationCoordinate2D {
  func regionWith(span input: MKCoordinateSpan) -> MKCoordinateRegion { return
    MKCoordinateRegion(
      center: self,
      span: input
    )
  }
}

extension UIGestureRecognizer {
  convenience init(target: Any?, action: Selector?, delegate: UIGestureRecognizerDelegate) {
    self.init(target: target, action: action)
    self.delegate = delegate
  }
}

class UIDoubleTapGestureRecognizer: UITapGestureRecognizer {
  override init(target: Any?, action: Selector?) {
    super.init(target: target, action: action)
    numberOfTapsRequired = 2
  }
}

extension UIViewController {
  var embeddedInNavigationController: UIViewController { return
    UINavigationController(rootViewController: self)
  }
}

extension Sequence where Iterator.Element == Int {
  func asIndexPathsWithSection(_ input: Int) -> [IndexPath] { return
    self.map { IndexPath(row: $0, section: input) }
  }
}

extension Sequence where Iterator.Element: Hashable {
  
  func indicesOfItemsNotFoundIn(_ input: [Iterator.Element]) -> [Int] { return
    self.enumerated().flatMap {
      input.contains($0.element) ? .none : $0.offset
    }
  }
  
  func itemsNotFoundIn(_ input: [Iterator.Element]) -> [Iterator.Element] { return
    self.flatMap {
      input.contains($0) ? .none : $0
    }
  }
  
}

extension UIAlertController {
  
  static func confirmingCallWithNumber(number: String, handler: @escaping (Bool) -> Void) -> UIAlertController {
    let output = UIAlertController(
      title: nil,
      message: number,
      preferredStyle: .actionSheet
    )
    output.addAction(
      UIAlertAction(
        title: "Cancel",
        style: .cancel,
        handler: { _ in
          handler(false)
        }
      )
    )
    output.addAction(
      UIAlertAction(
        title: "Call",
        style: .default,
        handler: { _ in
          handler(true)
        }
      )
    )
    return output
  }
  
}

extension UIView {
  func asTopRoundedWith(radius: CGFloat) -> CAShapeLayer {
    let output = CAShapeLayer()
    output.path = UIBezierPath(
      roundedRect: bounds,
      byRoundingCorners: [.topLeft, .topRight],
      cornerRadii: CGSize(width: radius, height: radius)
      ).cgPath
    return output
  }
}
