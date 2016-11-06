//
//  UICollectionViewLocations.swift
//  LocationPicker
//
//  Created by Brian Semiglia on 11/3/16.
//  Copyright © 2016 Brian Semiglia. All rights reserved.
//

import Foundation

final class UICollectionViewLocations:
  UICollectionView,
  UICollectionViewDelegate,
  UICollectionViewDataSource,
  UICollectionViewDelegateFlowLayout {
  
  var scrollDelegate: UIScrollViewDelegate?
  var itemCount: Int = 0
  var model: [LocationPicker.Model.Location] = [] {
    didSet {
      if model.count == oldValue.count {
        UIView.performWithoutAnimation {
          perform(
            batchUpdates: {
              self.reloadItems(at: self.indexPathsForVisibleItems)
          }
          )
        }
      } else {
        let deletions = oldValue.indicesOfItemsNotFoundIn(model).asIndexPathsWithSection(0)
        itemCount -= deletions.count
        deleteItems(at: deletions)
        let additions = model.indicesOfItemsNotFoundIn(oldValue).asIndexPathsWithSection(0)
        itemCount += additions.count
        insertItems(at: additions)
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    delegate = self
    dataSource = self
  }
  
  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)
    delegate = self
    dataSource = self
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    assert(
      delegate.map { $0 === self } ?? false && dataSource.map { $0 === self } ?? false,
      "UICollectionViewLocations may not have a delegate/data-source other than itself as it relies on the use of closures."
    )
  }
  
  func collectionView(_ collection: UICollectionView, cellForItemAt path: IndexPath) -> UICollectionViewCell { return
    UICollectionViewLocations.cell(
      cell: collection.dequeueReusableCell(
        withReuseIdentifier: "LocationPickerCell",
        for: path
        ) as! LocationPickerCell,
      decoratedWith: model[path.row],
      touchDownHandler: {}
    )
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return
    itemCount
  }
  
  func collectionView(_ collection: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt path: IndexPath) -> CGSize { return
    CGSize(
      width: collection.bounds.size.width - (LocationPicker.cardMarginHorizontal / (model.count > 1 ? 1.0 : 2.0)),
      height: collection.bounds.size.height
    )
  }
  
  static func cell(cell: LocationPickerCell, decoratedWith location: LocationPicker.Model.Location, touchDownHandler: @escaping (Void) -> Void) -> LocationPickerCell {
    cell.title = location.name
    cell.street = location.street
    cell.cityStateZip = location.cityStateZip
    cell.phoneNumber = location.phoneNumber
    cell.didReceiveTouchDown = touchDownHandler
    return cell
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollViewWillBeginDragging?(scrollView)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollViewDidScroll?(scrollView)
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollViewDidEndDecelerating?(scrollView)
  }
}
