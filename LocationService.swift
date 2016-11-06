//
//  LocationService.swift
//  LocationPicker
//
//  Created by Brian Semiglia on 10/5/16.
//  Copyright © 2016 Brian Semiglia. All rights reserved.
//

import NonCoalescingDispatchQueue

final class LocationService: LocationPickerOutputHandler {
  struct Event {
    let date: Date
    let model: LocationPicker.Model
  }
  var timeline: [Event] = []
  var picker: LocationPicker?
  var timer: NonCoalescingDispatchQueue?
  
  func locationPickerDidRequestReplay(_ picker: LocationPicker) {
    replay()
  }
  
  func locationPickerDidRequestReset(_ picker: LocationPicker) {
    timeline = []
  }
  
  func locationPicker(_ picker: LocationPicker, didSuggest model: LocationPicker.Model) {
    if timeline.count == 0 {
      picker.navigationItem.rightBarButtonItem = replayButton
    }
    let now = Date()
    DispatchQueue.global(qos: .default).sync {
      timeline = timeline + [Event(date: now, model: model)]
    }
    picker.model = model
    self.picker = picker
  }
  
  @objc func didReceiveEventFromReset(input: UIBarButtonItem) {
    timeline = []
  }
  
  @objc func didReceiveEventFromReplay(input: UIBarButtonItem) {
    replay()
  }
  
  var replayButton: UIBarButtonItem { return
    UIBarButtonItem(
      title: "Replay",
      style: .plain,
      target: self,
      action: #selector(didReceiveEventFromReplay(input:))
    )
  }
  
  func replay() {
    if let start = timeline.first?.date {
      picker?.navigationItem.rightBarButtonItem = nil
      timer = NonCoalescingDispatchQueue(
        events: timeline.map { event in
          NonCoalescingDispatchQueue.Event(
            delay: event.date.timeIntervalSince(start),
            action: {
              self.picker?.model = event.model
            }
          )
        },
        completion: {
          self.timeline = []
        }
      )
    }
  }
  
}
