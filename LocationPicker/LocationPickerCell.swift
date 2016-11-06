//
//  LocationPickerCell.swift
//  LocationPicker
//
//  Created by Brian Semiglia on 11/3/16.
//  Copyright © 2016 Brian Semiglia. All rights reserved.
//

import Foundation

final class LocationPickerCell: UICollectionViewCell {
  
  @IBInspectable var cornerRadius: CGFloat = 0
  var title: String? {
    didSet {
      titleLabel?.text = title
    }
  }
  var street: String? {
    didSet {
      streetLabel?.text = street
    }
  }
  var cityStateZip: String? {
    didSet {
      cityStateZipLabel?.text = cityStateZip
    }
  }
  var phoneNumber: String? {
    didSet {
      phoneNumberLabel?.text = phoneNumber
    }
  }
  var didReceiveTouchDown: ((Void) -> Void)?
  
  @IBOutlet var titleLabel: UILabel?
  @IBOutlet var streetLabel: UILabel?
  @IBOutlet var cityStateZipLabel: UILabel?
  @IBOutlet var phoneNumberLabel: UILabel?
  @IBOutlet var roundedBackground: UIView?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    titleLabel?.text = title
    streetLabel?.text = street
    cityStateZipLabel?.text = cityStateZip
    phoneNumberLabel?.text = phoneNumber
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.roundedBackground?.layer.mask = self.roundedBackground.map {
      $0.asTopRoundedWith(radius: cornerRadius)
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    didReceiveTouchDown?()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    didReceiveTouchDown = nil
  }
  
}
