# Sample Swift Project - iOS Example

If you are getting started with Swift and iOS development, or if you need a simple integration guide for the XYO Core Swift Library

## App Structure with Swift with Xcode and Cocoapods

Click here for an introduction to integrate a new Xcode project with CocoaPods

It is important to set up this project with CocoaPods so you can use dependencies to build the app

## Install Pod and Start Up Project

For the podfile, we will go ahead and use the latest `sdk-core-swift` 

```Pod
target 'MyApp' do 
  pod 'sdk-core-swift', '~> 3.0'
end
```

Then run a `pod install` from your terminal 

Once the pod installation is complete we open the workspace

```bash
open MyApp.xcworkspace
```

You should now see your Xcode workspace

## Start with Creating a Bound Witness

For this integration guide we will do our work in the view controller. 

We want to start by importing our `core_swift` and `objectmodel` SDKs

```swift
import sdk_core_swift
import sdk_objectmodel_swift
```

We should see the following in our `ViewController.swift`

```swift
class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
```

### Set up the values needed

In order for us to do a bound witness we need some objects and interfaces

```swift 
private let hasher = XyoSha256()
private let store = XyoInMemoryStorage()
private lazy var state = XyoStorageOriginStateRepository(storage: store)
private lazy var blocks = XyoStorageProviderOriginBlockRepository(storageProvider: store, hasher: hasher)
private lazy var conf = XyoRepositoryConfiguration(originState: state, originBlock: blocks)
private lazy var node = XyoOriginChainCreator(hasher: hasher, repositoryConfiguration: conf)
```

### Set up the listener

Let us add an extension to our `ViewController` to get the node listener that we'll need to display the hash representation of our bound witness 

```swift
extension ViewController : XyoNodeListener {
  // the library will bring some of these functions in, but we won't need most of them
  func onBoundWitnessStart() {}
  func onBoundWitnessEndFailure() {}
  func onBoundWitnessDiscovered(boundWitness: XyoBoundWitness) {} 

// this is where we bring in and display our bound witness
  func onBoundWitnessEndSuccess(boundWitness: XyoBoundWitness) {
    let hash = (try? boundWitness.getHash(hasher: hasher))?.getBuffer().toByteArray().toHexString()

  }
}
```

Before we can actually display the hash we need to set up the UI

### Set up the UI

Let's create the bound witness text to display, we will use the `UILabel` view class

```swift
private lazy var doBoundWitness: UILabel = {
  let text = UILabel()

  text.textColor = UIColor.black
  text.font = UIFont.systemFont(ofSize: 20, weight: .black)
  text.numberOfLines = 0

  return text
}()
```

We can now set the text in our listener which will be the `hash` 

```swift
func onBoundWitnessEndSuccess(boundWitness: XyoBoundWitness) {
  let hash = (try? boundWitness.getHash(hasher: hasher))?.getBuffer().toByteArray().toHexString()

  doBoundWitness.text = hash
}
```

In order for us to call the listener and get our hash, we need to create a button, we will use the `UIButton` class

```swift
private lazy var doBoundWitnessButton: UIButton = {
  let button = UIButton(type: UIButton.ButtonType.roundedRect)

  button.setTitle("Bound Witnesses", for: UIControl.State.normal)

  return button
}
```

Add logic to the button

```swift
private func layoutButton () {
    view.addSubview(doBoundWitnessButton)
    doBoundWitnessButton.translatesAutoresizingMaskIntoConstraints = false
    doBoundWitnessButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    doBoundWitnessButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

    let click = UITapGestureRecognizer(target: self, action: #selector(onButtonClick(_:)))
    doBoundWitnessButton.addGestureRecognizer(click)
}
```

Add interactivity to the button

```swift
@objc func onButtonClick (_ sender: UITapGestureRecognizer) {
  // error check without crashing
    try? node.selfSignOriginChain()
}
```

Now we have a button to activate the listener and display a bound witness hash on our primary view. 

### Set up the rest of the view

Before setting up the entire layout, let's create a title

```swift
private lazy var appTitle: UILabel = {
  let text = UILabel()

  text.textColor = UIColor.purple

  text.font = UIFont.systemFont(ofSize: 20, weight: .black)

  text.numberOfLines = 0

  return text
}()
```


We should create a layout where we can have our `viewDidLoad()` function call for what text and interactivity we want on this simple app

```swift
private func layout() {
  // bring in a title 
  appTitle.text = "Sample XYO App"

  view.addSubView(appTitle)
  view.addSubView(doBoundWitness)

  appTitle.translatesAutoresizingMaskIntoConstraints = false
  appTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
  appTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

  doBoundWitness.translatesAutoresizingMaskIntoConstraints = false
  doBoundWitness.bottomAnchor.constraint(equalTo: doBoundWitnessButton.topAnchor, constant: -80).isActive = true
  doBoundWitness.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
  doBoundWitness.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -80).isActive = true

}
```

Now we can include the layouts and see what we get

```swift
override func viewDidLoad() {
  super.viewDidLoad()
  node.addListener(key: "main", listener: self)
  layout()
  layoutButton()
}
```

Once you update the `viewDidLoad()`, your code should currently look like this

```swift
import UIKit
import sdk_core_swift
import sdk_objectmodel_swift

class ViewController: UIViewController {
    private let locationManager = CLLocationManager()
    private let hasher = XyoSha256()
    private let store = XyoInMemoryStorage()
    private lazy var state = XyoStorageOriginStateRepository(storage: store)
    private lazy var blocks = XyoStorageProviderOriginBlockRepository(storageProvider: store, hasher: hasher)
    private lazy var conf = XyoRepositoryConfiguration(originState: state, originBlock: blocks)
    private lazy var node = XyoOriginChainCreator(hasher: hasher, repositoryConfiguration: conf)

    private lazy var doBoundWitnessButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.roundedRect)
        
        button.setTitle("Bound Witness", for: UIControl.State.normal)
        
        return button
    }()

    private lazy var doBoundWitness: UILabel = {
        let text = UILabel()
        
        text.textColor = UIColor.black
        
        text.font = UIFont.systemFont(ofSize: 20, weight: .black)
        
        text.numberOfLines = 0
        
        return text
    }()

    private lazy var appTitle: UILabel = {
        let text = UILabel()
        
        text.textColor = UIColor.purple
        
        text.font = UIFont.systemFont(ofSize: 20, weight: .black)
        
        text.numberOfLines = 0
        
        return text
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad() 
        node.addListener(key: "main", listener: self)
        layout()
        layoutButton()
    }

    private func layout () {
        appTitle.text = "Sample XYO App"
        
        view.addSubview(appTitle)
        view.addSubview(doBoundWitness)
        
        appTitle.translatesAutoresizingMaskIntoConstraints = false
        appTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        appTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        doBoundWitness.translatesAutoresizingMaskIntoConstraints = false
                
        doBoundWitness.bottomAnchor.constraint(equalTo: doBoundWitnessButton.topAnchor, constant: -80).isActive = true
        doBoundWitness.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        doBoundWitness.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -80).isActive = true
    }

    private func layoutButton () {
        view.addSubview(doBoundWitnessButton)
        doBoundWitnessButton.translatesAutoresizingMaskIntoConstraints = false
        doBoundWitnessButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        doBoundWitnessButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        let click = UITapGestureRecognizer(target: self, action: #selector(onButtonClick(_:)))
        doBoundWitnessButton.addGestureRecognizer(click)
    }

    @objc func onButtonClick (_ sender: UITapGestureRecognizer) {
        print("doing bound witness")
        try? node.selfSignOriginChain()
    }

}

  extension ViewController : XyoNodeListener {
      // not needed
      func onBoundWitnessStart() {}
      func onBoundWitnessEndFailure() {}
      func onBoundWitnessDiscovered(boundWitness: XyoBoundWitness) {}

      func onBoundWitnessEndSuccess(boundWitness: XyoBoundWitness) {
          let hash = (try? boundWitness.getHash(hasher: hasher))?.getBuffer().toByteArray().toHexString()
          doBoundWitness.text = hash
      }

  }
}

```

Go ahead and save the project and run the build by clicking on the play button on the top left hand side of the Xcode IDE

