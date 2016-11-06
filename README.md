Location Picker is a view controller that reduces an array of Locations to a single Location. [Location] -> Location

#Approaches

##Value-Oriented
Effects are prioritized over events and their handlers. The view controller is seens as an implementation detail of achieving a reduced list. This is expressed simply and publicly.

```Swift
let input: [Location]
let output: (Location) -> Void
```

Versus the more traditional interface which usually doesn't make its resposibility clear or public.
```Swift
init() {}
func viewDidLoad() {}
func didSelectRowAtIndex(index: Int) {}
```

A value-orientation seperates concerns more evidently and prevents the view controller from becoming involved in the details of the orgin/destination of its inputs/outputs and results in a component that is more modular, reuseable.

##Declaratively Encapsulated
Commands are expressed as values leaving the caller free from having to know how to acheive the desired effect (what to call and when). Will the following work? It's not clear.
```Swift
viewController.load()
viewController.request = Request(query: "near Boston")
viewController.indicatorColor = .blue
```

The use of a declarative interface internalizes the responsibility of knowing the correct order of operation.
```Swift
Model(
  state: .loading(Request(query: "near boston")),
  indicatorColor: .blue
)
```

##Recursive and Linear
On callback (-layoutsubviews, -didInteractWithControl) the view controller returns only a suggested model. The caller must reinject the suggestion as a command in order for it to render. Because of this, state travels on a single predictable path from a single source of truth.

    Command -> Suggestion -> Validation? -> Command

##Verifiable
The combination of a linear path and commands-as-values allows for observability which allows for features like:

1. Testing
2. Rolling-back state (undo-manager)
3. Restoring state (from a previous session)
4. Playing-back state (animated feature-tutorials, analytics replays, crash replays)

![alt tag](https://github.com/BrianSemiglia/LocationPicker/blob/master/replay.gif)
