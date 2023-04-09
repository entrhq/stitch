[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![Compatibility](https://img.shields.io/badge/Swift%20compatibility-5.7%2B-green)]() [![Compatibility](https://img.shields.io/badge/iOS-13%2B-orange)]() [![Compatibility](https://img.shields.io/badge/Mac%20OS-10.15%2B-orange)]()

# Stitch
A lightweight, SwiftUI inspired, compile time safe dependency injection (DI) 
library providing dependency mapping without the need for codegen tooling. 

Stitch's compile time safety ensures confidence throughout development, if it compiles, you've configured correctly. 
No run time failures akin to typical dependency container implementations whenever a dependency has not been registered.

Stitch models its dependency map after the SwiftUI `EnvironmentValues` structure, 
and provides appropriate `@propertyWrapper` implementations for retrieving objects from the map. 

## Stitch in a pinch
Using Stitch in your application is straightforward and aims to provide rich functionality with minimal boilerplate or code generation. Stitch achieves its compile time safety through the use of the DependencyMap which encapsulates all dependencies for resolution.

To register a dependency:
1. Declare a dynamic property within an extension of `DependencyMap`.
2. Create a `DependencyKey` to store the initial/default value for the dependency.
3. Resolve and register the key inside the dynamic property.

```swift
/// Protocol abstraction for our dependency
protocol Logger {
    func log(message: String) 
}

extension DependencyMap {
    private struct LoggerKey: DependencyKey {
        static var dependency: any Logger = RemoteLogger()
    }

    var logger: any Logger {
        get { resolve(key: LoggerKey.self) }
        set { register(key: LoggerKey.self, dependency: newValue) }
    }
}
```

This dependency can now be resolved by the Stich propertyWrappers from anywhere in the codebase, using the dynamic property keyPath for lookup.

```swift
class Model {
    @Stitch(\.logger) var logger
    
    func doSomething() {
        logger.log("Logging a message")
    }
}
```
This is Stitch at a high level, simple to implement with flexibility for both concrete and protocol DI. For detailed explanations and advanced implementation, refer to the [Advanced stitching](#advanced-stitching) section.

## Get stitching
To get started with Stitch, you must first install it as a dependency in your project. 

__Using [Swift Package Manager](https://github.com/apple/swift-package-manager):__
You can add Stitch to an Xcode project by adding it as a package dependency:
1. Select File -> Add packages
2. Enter https://github.com/entrhq/stitch.git as the package repository URL.
3. Add the Stitch library to your desired target.

Adding Stitch to a Swift Package:
```swift
dependencies: [
    .package(url: "https://github.com/entrhq/stitch.git", .upToNextMajor(from: "VERSION")),
],
targets: [
    .target(
        name: "YOUR PACKAGE",
        dependencies: [
            "Stitch",
        ]
    ),
],
```

## Advanced stitching
- [StitchObservable](#using-@stitchobservable)
- [StichPublished](#using-@stitchpublished)

##### Using @StitchObservable
Stitch aims to provide flexible use of dependencies within the SwiftUI environment extending the traditional SwiftUI implementations with further functionality. Out of the box, SwiftUI provides both `ObservableObject` and the `@ObservedObject` property wrapper, allowing developers to push state into its own object to manage its lifecycle. This works well when using concrete dependencies in your views:

```swift
class Model: ObservableObject {
    @Published var name: String
}

struct HomeView: View {
    @ObservedObject var model: Model
    
    init(model: Model) {
        self.model = model
    }
    
    var body: some View {
        Text("Welcome, \(model.name)")
    }
}
```

The above implementation would be easy to manage, and your previews would still be managable:
```swift
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: Model())
    }
}
```

Now in a real world, our dependencies may not be that straight forward. They may interact with other layers and retrieve data, or make a network request. This in turn, would break our previews, how would we go about nicely creating a useable object for our preview instance.

```swift
class Model: ObservableObject {
    var service: Service
    var database: Database
    
    init(service: Service, database: Database) {
        self.service = service
        self.database = database
    }
    
    @Published var name: String
    @Published var isLoaded: Bool
    
    func fetchName() { ... }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            model: Model(
                service: // How do we create our service nicely?
                database: // How do we create our database nicely?
            )
        )
    }
}
```

You might start to reach for a protocol to help clean up our model and hide its implementation details. After all, our view really only cares about both the name and isLoaded `@Published` properties, not the other dependencies and implementation details.

```swift
protocol Modelling: ObservableObject {
    var name: String { get set }
    var isLoaded: Bool { get set }
}

class Model: Modelling {
    var service: Service
    var database: Database
    
    init(service: Service, database: Database) {
        self.service = service
        self.database = database
    }
    
    @Published var name: String
    @Published var isLoaded: Bool
    
    func fetchName() { ... }
}
```

This hides our model's implementation detail successfully, and looks as if it will help us create a meaningful mock for the preview. We quickly come to realise however, that SwiftUI's `@ObservedObject` property wrapper only works with concrete types. 

Stitch introduces a new property wrapper `@StitchObservable` as a way to inject this dependency by its protocol type into a SwiftUI view, and still leverage its @Published property state updates for view recomposition.

To do this, simply add the `AnyObservableObject` conformance to your already conforming `ObservableObject`, provide an entry to the `DependencyMap` as demonstrated above, and replace the `@ObservedObject` wrapper with `@StitchObservable`

```swift
protocol Modelling: ObservableObject, AnyObservableObject {
    var name: String { get set }
    var isLoaded: Bool { get set }
}

struct HomeView: View {
    @StitchObservable(\.model) var model
    
    var body: some View {
        Text("Welcome, \(model.name)")
    }
}
```

Our view now will recompose just the same as before with the @ObservedObject, whenever our @Published properties are changed, but will only be exposed to the properties declared in the protocol contract. As well as this, our preview implementation just got even easier. Now we can provide a mock just for previews, allowing us to display test data whilst developing our view.

```swift
struct HomeView_Previews: PreviewProvider, DependencyMocker {
    class MockModel: Modelling {
        @Published var name = "Mock name"
        @Published var isLoading = false
    }
    
    static var previews: some View {
        mockInViewScope(\.model, mock: MockModel())
        HomeView()
    }
}
```
Our model can now be easily mocked, without providing irrelevant / hard to create dependencies from within the preview scope. 

##### Using @StitchPublished
Stitch extends the functionality of `@Published` properties inside protocol types, and provides the same Publisher behaviour for these properties to external consumers. Normally, one can access the `Publisher` of the property inside of a concrete class, but as discussed above, when hiding implementation detail and enabling IOC / DI, we lose this functionality. Our protocol definitions did not allude to our properties being annotated with `@Published` and no longer allow consumers to subscribe to these publishers.

This is where Stitch introduces the `@StitchPublished` property wrapper. Similar to the above `@StitchObservable`, this property wrapper wraps our protocol type and forwards publish events to the consumer of the property wrapper. However, StitchPublished gives consumers access outside of a view scope, providing them with subscribers on properties inside of the protocol. 

This allows us to subscribe to state changes inside objects outside our view lifecycle and perform actions on the mutated value. The following code subscribes to an auth state, and executes functionality whenever the user's auth state changes:

The `@StitchPublished` wrapper provides a projected value accessor prefix ($), which allows dynamic member lookup of the object's properties. Each property returning the value wrapped by a Publisher. This publisher will publish updated value events __*only*__ if its underlying value changes, not if the object or parts of the object change in isolation. As `@Published` wrappers notify the objectWillChange publisher that it's values have changed, but not specifically which value changed, the `StitchPublished` wrapper does its own diffing internally, and only propogates state changes to property publishers who's value has changed. This behaves similarly to how the SwiftUI prepares the view for an update, only updating values that changed after completing a diff.

> Note: Only properties conforming to `Equatable` can be accessed through the $ prefix, due to the internal diff requiring equatable generic conformances.
```swift
protocol AuthStoring: ObservableObject, AnyObservableObject {
    var isLoggedIn: Bool { get set }
}

class AuthStore: AuthStoring {
    @Published var isLoggedIn = false
}

class SomeService {
    @StitchPublished(\.authStore) var store
    
    ...
    
    func setup() {
        $store.isLoggedIn.sink { loggedIn in
            if loggedIn {
                // do something logged in
            } else {
                // do something logged out
            }
        }
        .store(in: &cancellables)
    }
}
```

This becomes useful when we want to store relevant state in their own separate ObservableObjects, whilst still having cross cutting interactions, further aiding us in following a reactive composition based architecture.

## License

Stitch is an open-source and free software released under [Apache 2.0](https://choosealicense.com/licenses/apache-2.0/)
