Location Picker is a view controller that reduces an array of Locations to a single Location. [Location] -> Location

#Approaches

##Value-Oriented
Effects are prioritized over events and their handlers. The view controller is seen as an implementation detail of achieving a reduced list. This is expressed simply and publicly.

```Swift
struct ViewModel {
  struct Location {
    let coordinate: CLLocationCoordinate2D
    let isSelected: Bool
  }
  let locations: [Location]
}

class ViewController {
  let input: ViewModel
  let output: (ViewModel) -> Void
}
```

Versus the more traditional interface which usually doesn't make its resposibility clear or public.
```Swift
class ViewController {
  init() {}
  func viewDidLoad() {}
  func didSelectRowAtIndex(index: Int) {}
}
```

A value-orientation seperates concerns more evidently and prevents the view controller from becoming involved in the details of the orgin/destination of its inputs/outputs and results in a component that is more modular, reuseable.

##Declaratively Encapsulated
Commands are expressed as values leaving the caller free from having to know how to acheive the desired effect (what to call and when). Traditional interfaces are prodecuraly coupled and calling commands out of order can produce issues.
```Swift
viewController.load()
viewController.request = Request(query: "near Boston")
viewController.indicatorColor = .blue
```

The use of a declarative interface internalizes the responsibility of knowing the correct order of operation.
```Swift
viewController.input = Model(
  state: .loading(Request(query: "near boston")),
  indicatorColor: .blue
)
```

##Recursive and Linear
On callback (-layoutsubviews, -didInteractWithControl) the view controller returns only a suggested model. The caller must reinject the suggestion as a command in order for it to render. Because of this, state travels on a single predictable path from a single source of truth.

    Command -> Suggestion -> Validation? -> Command

##Observable
The combination of a linear path and commands-as-values allows for observability which allows for features like:

1. Testing
2. State Restoration (from a previous session, undo-manager)
3. State Playback (animated feature-tutorials, analytics replays, crash replays)

![alt tag](https://github.com/BrianSemiglia/LocationPicker/blob/master/replay.gif)
