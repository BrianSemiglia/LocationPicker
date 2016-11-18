//
//  ViewController.swift
//  LocationPicker
//
//  Created by Brian Semiglia on 9/18/16.
//  Copyright © 2016 Brian Semiglia. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import MBProgressHUD

protocol LocationPickerOutputHandler {
  func locationPicker(_: LocationPicker, didSuggest model: LocationPicker.Model)
  func locationPickerDidRequestReset(_: LocationPicker)
  func locationPickerDidRequestReplay(_: LocationPicker)
}

final class LocationPicker:
  UIViewController,
  MKMapViewDelegate,
  UITextFieldDelegate,
  UIScrollViewDelegate,
  UIGestureRecognizerDelegate {
  
  struct Model {
    let locations: [Location]
    let state: State
    let shouldRender: Bool
    let scrollLocation: MKCoordinateRegion
    let pickerScroll: CGPoint
    
    struct Location {
      var isSelected: Bool
      var isOpeningMaps: Bool
      var callState: CallState
      let name: String
      let street: String
      let cityStateZip: String
      let phoneNumber: String
      let hoursShippingOptionsHTML: String
      let selectedImage: UIImage?
      let deselectedImage: UIImage?
      let coordinate: CLLocationCoordinate2D
      let backing: Any
      
      enum CallState {
        case idle
        case confirming
        case calling
      }
    }
    
    enum State {
      case awaitingLocations
      case awaitingSearchResults
      case presentingDetails
      case presentingLocationsAll
      case presentingLocationsSelected
      case presentingLocationsScrolling
      case selectingLocation
    }
  }
  
  var outputHandler: LocationPickerOutputHandler?
  
  @IBOutlet var locationPickerBottomToSuperview: NSLayoutConstraint?
  @IBOutlet var locationDetailBottomToSuperview: NSLayoutConstraint?
  @IBOutlet var searchFieldTopMarginConstraint: NSLayoutConstraint?
  @IBOutlet var searchFieldBottomMarginConstraint: NSLayoutConstraint?
  @IBOutlet var detail: UIView?
  @IBOutlet var picker: UICollectionViewLocations? {
    didSet {
      picker?.scrollDelegate = self
    }
  }
  @IBOutlet var map: MKMapView? {
    didSet {
      map?.gestureRecognizers = newRecognizers
    }
  }
  
  @IBOutlet var searchField: UITextField?
  @IBOutlet var detailTitle: UILabel?
  @IBOutlet var detailStreet: UILabel?
  @IBOutlet var detailCityStateZip: UILabel?
  @IBOutlet var detailPhoneNumber: UILabel?
  @IBOutlet var detailChangeLocation: UIButton?
  @IBOutlet var detailHoursShippingOptions: UIWebView?

  var isUserScrolling = false
  static let cardMarginHorizontal: CGFloat = 40.0
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  func didReceiveEventFromReplay(input: UIBarButtonItem) {
    outputHandler?.locationPickerDidRequestReplay(self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let model = model {
      outputHandler?.locationPicker(
        self,
        didSuggest: model.copy(
          shouldRender: true
        )
      )
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    if let model = model, model.state != .selectingLocation {
      outputHandler?.locationPicker(
        self,
        didSuggest: model.copy(
          shouldRender: false
        )
      )
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let model = model {
      outputHandler?.locationPicker(
        self,
        didSuggest: model.copy(
          shouldRender: true
        )
      )
    }
  }
  
  override func willMove(toParentViewController parent: UIViewController?) {
    super.willMove(toParentViewController: parent)
    if let model = model, parent != nil /* isBeingDismissed */ {
      outputHandler?.locationPicker(
        self,
        didSuggest: model.copy(
          shouldRender: false
        )
      )
    }
  }

  @IBAction func didReceiveEventFromAddress(recognizer: UITapGestureRecognizer) {
    if let model = model {
      outputHandler?.locationPicker(
        self,
        didSuggest: model.copy(
          locations: model.locations.map {
            $0.isSelected ? $0.copy(isOpeningMaps: true) : $0
          }
        )
      )
    }
  }
  
  @IBAction func didReceiveEventFromPhoneNumber(recognizer: UITapGestureRecognizer) {
    if let model = model {
      outputHandler?.locationPicker(
        self,
        didSuggest: model.copy(
          locations: model.locations.map {
            $0.isSelected ? $0.copy(callState: .confirming) : $0
          }
        )
      )
    }
  }
  
  @IBAction func didReceiveEventFromChangeLocation(_ sender: UIButton) {
    if let model = model {
      outputHandler?.locationPicker(
        self,
        didSuggest: model.copy(
          state: .presentingLocationsAll
        )
      )
    }
  }
  
  @IBAction func didReceiveEventFromSelectLocation(_ sender: UIButton) {
    if let model = model {
      outputHandler?.locationPicker(
        self,
        didSuggest: model.copy(
          state: .presentingDetails
        )
      )
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if let copy = model {
      outputHandler?.locationPicker(
        self,
        didSuggest: copy
      )
    }
  }
  
  var showingDetailsHidingPickerSearchPriorities: [NSLayoutConstraint : Float] { return [
    self.locationPickerBottomToSuperview!: 998,
    self.locationDetailBottomToSuperview!: 999,
    self.searchFieldTopMarginConstraint!: 998,
    self.searchFieldBottomMarginConstraint!: 999
  ]}

  var hidingPickerSearchDetailsPriorities: [NSLayoutConstraint : Float] { return [
    self.searchFieldTopMarginConstraint!: 998,
    self.searchFieldBottomMarginConstraint!: 999,
  ]}

  var showingPickerSearchHidingDetailsPriorities: [NSLayoutConstraint : Float] { return [
    self.locationPickerBottomToSuperview!: 999,
    self.locationDetailBottomToSuperview!: 998,
    self.searchFieldTopMarginConstraint!: 998,
    self.searchFieldBottomMarginConstraint!: 999,
  ]}
  
  var showingPickerSearchHidingDetailsMapLayoutMargins: [MKMapView: UIEdgeInsets] { return [
    self.map!: UIEdgeInsets(
      top: self.searchField!.frame.origin.y + self.searchField!.frame.size.height,
      left: 0,
      bottom: self.picker!.bounds.size.height,
      right: 0
    )
  ]}

  var showingPickerHidingDetailsSearchMapLayoutMargins: [MKMapView: UIEdgeInsets] { return [
    self.map!: UIEdgeInsets(
      top: 0,
      left: 0,
      bottom: self.detail!.bounds.size.height,
      right: 0
    )
  ]}
  
  var showingSearchHidingPickerDetailsMapLayoutMargins: [MKMapView: UIEdgeInsets] { return [
    self.map!: UIEdgeInsets(
      top: self.searchField!.frame.origin.y + self.searchField!.frame.size.height,
      left: 0,
      bottom: 0,
      right: 0
    )
  ]}
  
  var hidingPickerSearchDetailsMapLayoutMargins: [MKMapView: UIEdgeInsets] { return [
    self.map!: UIEdgeInsets.zero
  ]}
  
  var showingPickerHidingDetailsAlphas: [UIView: CGFloat] { return [
    self.picker!: 1,
    self.detail!: 0
  ]}

  var showingDetailsHidingPickerAlphas: [UIView: CGFloat] { return [
    self.picker!: 0,
    self.detail!: 1
  ]}

  var hidingPickerDetailsAlphas: [UIView: CGFloat] { return [
    self.picker!: 0,
    self.detail!: 0
  ]}
  
  func labelTextsFor(location input: LocationPicker.Model.Location) -> [UILabel: String] { return [
    self.detailTitle!: input.name,
    self.detailStreet!: input.street,
    self.detailCityStateZip!: input.cityStateZip,
    self.detailPhoneNumber!: input.phoneNumber
  ]}
  
  var model: Model? {
    didSet {
      if model != oldValue {
        if let new = model, !isViewLoaded {
          outputHandler?.locationPicker(
            self,
            didSuggest: new.copy(
              shouldRender: false
            )
          )
        } else if let new = model, new.shouldRender {
          view.setNeedsLayout()
          map?.setNeedsLayout()
          switch new.state {
            
          case .selectingLocation:
            outputHandler?.locationPicker(
              self,
              didSuggest: new.copy(
                state: oldValue?.state ?? .presentingLocationsAll
              )
            )
          
          case .awaitingLocations:
            title = "Loading"
            UIView.animate(
              withDuration: oldValue.map { $0.shouldRender ? 0.33 : 0 } ?? 0,
              animations: {
                for x in self.showingSearchHidingPickerDetailsMapLayoutMargins { x.key.layoutMargins = x.value }
                for x in self.hidingPickerSearchDetailsPriorities { x.key.priority = x.value }
                for x in self.hidingPickerDetailsAlphas { x.key.alpha = x.value }
                self.view.layoutIfNeeded()
                self.map?.layoutIfNeeded()
              }
            )
            MBProgressHUD.showAdded(
              to: self.view,
              animated: oldValue?.shouldRender ?? false
            )
            
          case .presentingDetails:
            title = "Details"
            MBProgressHUD.hide(
              for: view,
              animated: oldValue?.shouldRender ?? false
            )
            UIView.animate(
              withDuration: oldValue.map { $0.shouldRender ? 0.33 : 0 } ?? 0,
              animations: {
                self.detailChangeLocation?.isHidden = new.locations.count <= 1
                for x in self.showingDetailsHidingPickerAlphas { x.key.alpha = x.value }
                for x in self.showingDetailsHidingPickerSearchPriorities { x.key.priority = x.value }
                for x in self.showingPickerHidingDetailsSearchMapLayoutMargins { x.key.layoutMargins = x.value }
                if let selected = new.locations.selected {
                  for x in self.labelTextsFor(location: selected) { x.key.text = x.value }
                  self.detailHoursShippingOptions?.loadHTMLString(
                    selected.hoursShippingOptionsHTML,
                    baseURL: nil
                  )
                }
                self.view.layoutIfNeeded()
                self.map?.layoutIfNeeded()
              }
            )
            if let selected = new.locations.selected {
              map?.render(
                annotation: selected.asAnnotation
              )
              map?.setRegion(
                selected.coordinate.regionWith(span: .zoomedOut),
                animated: oldValue?.shouldRender ?? false
              )
            }
            
          case .presentingLocationsAll:
            title = "All"
            MBProgressHUD.hide(
              for: view,
              animated: oldValue?.shouldRender ?? false
            )
            if new.locations.count > 1 {
              UIView.animate(
                withDuration: oldValue.map { $0.shouldRender ? 0.33 : 0 } ?? 0,
                animations: {
                  self.showingPickerHidingDetailsAlphas.forEach {  $0.key.alpha = $0.value }
                  self.showingPickerSearchHidingDetailsPriorities.forEach { $0.key.priority = $0.value }
                  self.showingPickerSearchHidingDetailsMapLayoutMargins.forEach { $0.key.layoutMargins = $0.value }
                  self.view.layoutIfNeeded()
                  self.map?.layoutIfNeeded()
                },
                completion: { finished in
                  self.map?.render(annotations: new.locations.map { $0.asAnnotation })
                  if oldValue?.state == .awaitingLocations || oldValue == nil {
                    self.map?.showAnnotations(
                      self.map?.annotations ?? [],
                      animated: oldValue?.shouldRender ?? false
                    )
                  }
                }
              )
              picker?.model = model?.locations ?? []
              self.picker?.possiblyScrollToItem(
                at: IndexPath(
                  row: new.locations.indexOfSelected ?? 0,
                  section: 0
                ),
                at: .centeredHorizontally,
                animated: oldValue?.shouldRender ?? false
              )
            } else if new.locations.count == 1 {
              outputHandler?.locationPicker(
                self,
                didSuggest: new.copy(
                  state: .presentingDetails
                )
              )
            }
            
          case .presentingLocationsSelected:
            title = "Selected"
            MBProgressHUD.hide(
              for: view,
              animated: oldValue?.shouldRender ?? false
            )
            if new.locations.count > 1 {
              UIView.animate(
                withDuration: oldValue.map { $0.shouldRender ? 0.33 : 0 } ?? 0,
                animations: {
                  self.showingPickerHidingDetailsAlphas.forEach { $0.key.alpha = $0.value }
                  self.showingPickerSearchHidingDetailsPriorities.forEach { $0.key.priority = $0.value }
                  self.showingPickerSearchHidingDetailsMapLayoutMargins.forEach { $0.key.layoutMargins = $0.value }
                  self.map?.render(
                    annotations: new.locations.map { $0.asAnnotation }
                  )
                  if let selected = new.locations.selected, let map = self.map {
                    map.setRegion(
                      selected.coordinate.regionWith(span: map.region.span),
                      animated: oldValue?.shouldRender ?? false
                    )
                  }
                  self.view.layoutIfNeeded()
                  self.map?.layoutIfNeeded()
                }
              )
              picker?.model = model?.locations ?? []
              picker?.possiblyScrollToItem(
                at: IndexPath(
                  row: new.locations.indexOfSelected ?? 0,
                  section: 0
                ),
                at: .centeredHorizontally,
                animated: oldValue?.shouldRender ?? false
              )
            } else if new.locations.count == 1 {
              outputHandler?.locationPicker(
                self,
                didSuggest: new.copy(
                  state: .presentingDetails
                )
              )
            }
            
          case .presentingLocationsScrolling:
            map?.region = new.scrollLocation
            picker?.contentOffset = new.pickerScroll
            
          case .awaitingSearchResults:
            title = "Awaiting Search Results"
            UIView.animate(
              withDuration: oldValue.map { $0.shouldRender ? 0.33 : 0 } ?? 0,
              animations: {
                self.hidingPickerSearchDetailsPriorities.forEach { $0.key.priority = $0.value }
                self.hidingPickerSearchDetailsMapLayoutMargins.forEach { $0.key.layoutMargins = $0.value }
                self.view.layoutIfNeeded()
                self.map?.layoutIfNeeded()
              }
            )
            MBProgressHUD.hide(
              for: self.view,
              animated: oldValue?.shouldRender ?? false
            )
          }
          
          if let selected = new.locations.selected {
            switch selected.callState {
            case .confirming:
              self.present(
                UIAlertController.confirmingCallWithNumber(
                  number: selected.phoneNumber,
                  handler: { confirmed in
                    self.outputHandler?.locationPicker(
                      self,
                      didSuggest: new.copy(
                        locations: new.locations.map {
                          $0.isSelected ? $0.copy(callState: confirmed ? .calling : .idle) : $0
                        }
                      )
                    )
                  }
                ),
                animated: true,
                completion: nil
              )
            default:
              break
            }
          }
        }
      }
    }
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    isUserScrolling = true
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if
      let model = model,
      let view = scrollView as? UICollectionView, isUserScrolling,
      let progress = view.scrollPercentageFor(
        cellWidth: view.bounds.size.width - LocationPicker.cardMarginHorizontal
      )
    {
      
      let cardCenter = progress < 0.5 ? view.bounds.size.width * 0.25 : view.bounds.size.width * 0.75
      let cardCenterWithOffset = CGPoint(x: view.contentOffset.x + cardCenter, y: 0)
      let current = view.indexPathForItem(at: cardCenterWithOffset).map { $0.row - (progress < 0.5 ? 0 : 1) } ?? 0
      let next = current + 1
      
      if let location = model
        .locations[current - (next < model.locations.count ? 0 : 1)]
        .coordinate
        .pointUntil(
          destination: model.locations[next < model.locations.count ? next : current].coordinate,
          percentage: Double(progress + (next < model.locations.count ? 0 : 1))
        ) {
        
        outputHandler?.locationPicker(
          self,
          didSuggest: model.copy(
            state: .presentingLocationsScrolling,
            scrollLocation: MKCoordinateRegion(center: location, span: map!.region.span),
            pickerScroll: view.contentOffset
          )
        )
      }
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    isUserScrolling = false
    if let model = model, let view = scrollView as? UICollectionView {
      outputHandler?.locationPicker(
        self,
        didSuggest: model.copy(
          locations: model.locations.enumerated().map {
            $0.element.copy(
              isSelected: view.centerIndex?.row == $0.offset
            )
          },
          state: .presentingLocationsSelected
        )
      )
    }
  }
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if let model = model {
      outputHandler?.locationPicker(
        self,
        didSuggest: model.copy(state: .awaitingSearchResults)
      )
    }
    return false
  }
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    if
      let model = model,
      let annotation = view.annotation as? MKPointAnnotation.Identifiable,
      let backing = annotation.backing as? LocationPicker.Model.Location {
        outputHandler?.locationPicker(
          self,
          didSuggest: model.copy(
            locations: model.locations.map {
              $0.copy(
                isSelected: $0.coordinate == backing.coordinate
              )
            },
            state: .presentingLocationsSelected
          )
        )
    }
  }

  func didReceiveEventFromMap(recognizer: UIGestureRecognizer) {
    if let model = model {
      outputHandler?.locationPicker(
        self,
        didSuggest: model.copy(
          state: .presentingLocationsScrolling,
          scrollLocation: map?.region
        )
      )
    }
  }
  
  func gestureRecognizer(_ first: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith second: UIGestureRecognizer) -> Bool {
    return true
  }
  
  var newRecognizers: [UIGestureRecognizer] { return [
    UIPanGestureRecognizer(
      target: self,
      action: #selector(didReceiveEventFromMap(recognizer:)),
      delegate: self
    ),
    UIPinchGestureRecognizer(
      target: self,
      action: #selector(didReceiveEventFromMap(recognizer:)),
      delegate: self
    ),
    /* double tap fires before map zoom but doesn't capture map transition */
    UIDoubleTapGestureRecognizer(
      target: self,
      action: #selector(didReceiveEventFromMap(recognizer:)),
      delegate: self
    )
  ]}
}

extension LocationPicker.Model {
  func firstLocationMatching(annotation input: MKAnnotation) -> LocationPicker.Model.Location? { return
    locations.filter {
      $0.coordinate.latitude == input.coordinate.latitude &&
      $0.coordinate.longitude == input.coordinate.longitude
    }.first
  }
}

extension UICollectionView {
  
  var centerIndex: IndexPath? { return
    indexPathForItem(at:
      CGPoint(
        x: (bounds.size.width / 2.0) + contentOffset.x,
        y: (bounds.size.height / 2.0) + contentOffset.y
      )
    )
  }
  
  func scrollPercentageFor(cellWidth: CGFloat) -> CGFloat? {
    if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
      switch contentOffset.x {
      case let x where x > contentSize.width - ((cellWidth + layout.minimumInteritemSpacing) * 2) - layout.sectionInset.right:
        return fmod(
          contentOffset.x +
          layout.minimumInteritemSpacing +
          layout.sectionInset.right,
          cellWidth +
          layout.minimumInteritemSpacing
        ) / (cellWidth + layout.minimumInteritemSpacing)
      case let x where x < cellWidth:
        return x / cellWidth
      default:
        return fmod(
          contentOffset.x - cellWidth,
          cellWidth + layout.minimumInteritemSpacing
        ) / (cellWidth + layout.minimumInteritemSpacing)
      }
    } else {
      return nil
    }
  }
}

extension LocationPicker.Model {
  
  func copy(
    locations: [Location]? = nil,
    state: State? = nil,
    shouldRender: Bool? = nil,
    scrollLocation: MKCoordinateRegion? = nil,
    pickerScroll: CGPoint? = nil
  ) -> LocationPicker.Model { return
    LocationPicker.Model(
      locations: locations ?? self.locations,
      state: state ?? self.state,
      shouldRender: shouldRender ?? self.shouldRender,
      scrollLocation: scrollLocation ?? self.scrollLocation,
      pickerScroll: pickerScroll ?? self.pickerScroll
    )
  }
  
}

extension LocationPicker.Model.Location {
  
  var asAnnotation: MKPointAnnotation.Identifiable { return
    MKPointAnnotation.Identifiable(
      isSelected: self.isSelected,
      coordinate: self.coordinate,
      title: self.name,
      backing: self
    )
  }
  
  func copy(
    isSelected: Bool? = nil,
    isOpeningMaps: Bool? = nil,
    callState: CallState? = nil,
    name: String? = nil,
    street: String? = nil,
    cityStateZip: String? = nil,
    phoneNumber: String? = nil,
    hoursShippingOptionsHTML: String? = nil,
    selectedImage: UIImage? = nil,
    deselectedImage: UIImage? = nil,
    location: CLLocationCoordinate2D? = nil,
    backing: Any? = nil
  ) -> LocationPicker.Model.Location { return
    LocationPicker.Model.Location(
      isSelected: isSelected ?? self.isSelected,
      isOpeningMaps: isOpeningMaps ?? self.isOpeningMaps,
      callState: callState ?? self.callState,
      name: name ?? self.name,
      street: street ?? self.street,
      cityStateZip: cityStateZip ?? self.cityStateZip,
      phoneNumber: phoneNumber ?? self.phoneNumber,
      hoursShippingOptionsHTML: hoursShippingOptionsHTML ?? self.hoursShippingOptionsHTML,
      selectedImage: selectedImage ?? self.selectedImage,
      deselectedImage: deselectedImage ?? self.deselectedImage,
      coordinate: location ?? self.coordinate,
      backing: backing ?? self.backing
    )
  }
  
}

extension Sequence where Iterator.Element == LocationPicker.Model.Location {
  
  var selected: LocationPicker.Model.Location? { return
    self.filter { $0.isSelected }.first
  }
  
  var indexOfSelected: Int? { return
    self.enumerated().reduce(
      Optional<Int>.none,
      { sum, x in
        sum ?? (x.element.isSelected ? x.offset : nil)
      }
    )
  }
  
}

extension Sequence where Iterator.Element == LocationPicker.Model.Location {
  func withBackingEqualTo(_ input: LocationPicker.Model.Location) -> LocationPicker.Model.Location? { return
    self.filter { $0 == input }.first
  }
  var asDeselected: [LocationPicker.Model.Location] { return
    self.map { $0.copy(isSelected: false) }
  }
}

extension LocationPicker.Model.Location: Equatable {
  static func ==(left: LocationPicker.Model.Location, right: LocationPicker.Model.Location) -> Bool { return
    left.isSelected == right.isSelected &&
    left.callState == right.callState &&
    left.isOpeningMaps == right.isOpeningMaps &&
    left.coordinate == right.coordinate &&
    left.name == right.name &&
    left.street == right.street &&
    left.cityStateZip == right.cityStateZip &&
    left.hoursShippingOptionsHTML == right.hoursShippingOptionsHTML
  }
}

extension LocationPicker.Model.Location: Hashable {
  public var hashValue: Int { return
    String(
      (isSelected ? "YES" : "NO") +
      (isOpeningMaps ? "YES" : "NO") +
      String(coordinate.latitude) +
      String(coordinate.longitude) +
      name +
      street +
      cityStateZip +
      hoursShippingOptionsHTML
    ).hash
  }
}

extension LocationPicker.Model: Equatable {
  static func ==(left: LocationPicker.Model, right: LocationPicker.Model) -> Bool { return
    left.scrollLocation == right.scrollLocation &&
    left.shouldRender == right.shouldRender &&
    left.state == right.state &&
    left.locations == right.locations
  }
}

extension LocationPicker {
  static var fromStoryboard: LocationPicker { return
    UIStoryboard(name: "LocationPicker", bundle: nil).instantiateViewController(withIdentifier: "LocationPicker") as! LocationPicker
  }
}
