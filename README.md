[logo]: https://cdn.xy.company/img/brand/XY_Logo_GitHub.png

[![logo]](https://xy.company)

# sdk-core-swift

[![Maintainability](https://api.codeclimate.com/v1/badges/587ae96e86057b6b6178/maintainability)](https://codeclimate.com/repos/5c4a7a7372b7b2029d008b34/maintainability) [![](https://img.shields.io/cocoapods/v/sdk-core-swift.svg?style=flat)](https://cocoapods.org/pods/sdk-core-swift) [![Test Coverage](https://api.codeclimate.com/v1/badges/587ae96e86057b6b6178/test_coverage)](https://codeclimate.com/repos/5c4a7a7372b7b2029d008b34/test_coverage)


| Branches        | Status           |
| ------------- |:-------------:|
| Master      | [![Build Status](https://travis-ci.org/XYOracleNetwork/sdk-core-swift.svg?branch=master)](https://travis-ci.org/XYOracleNetwork/sdk-core-swift) |
| Develop      | [![Build Status](https://travis-ci.org/XYOracleNetwork/sdk-core-swift.svg?branch=develop)](https://travis-ci.org/XYOracleNetwork/sdk-core-swift)      |



A library to preform all core XYO Network functions.
This includes creating an origin chain, maintaining an origin chain, negotiations for talking to other nodes, and other basic functionality.
The library has heavily abstracted modules so that all operations will work with any crypto, storage, networking, ect.

The XYO protocol for creating origin-blocks is specified in the [XYO Yellow Paper](https://docs.xyo.network/XYO-Yellow-Paper.pdf). In it, it describes the behavior of how a node on the XYO network should create Bound Witnesses. Note, the behavior is not coupled with any particular technology constraints around transport layers, cryptographic algorithms, or hashing algorithms.

[Here](https://github.com/XYOracleNetwork/spec-coreobjectmodel-tex) is a link to the core object model that contains an index of major/minor values and their respective objects.

## Getting Started

The most common interface to this library through creating an origin chain creator object. Through an origin chain creator object one can create and maintain an origin chain. 

```swift
// this object will be used to hash items whiten the node
let hasher = XyoSha256()

// this is used as a key value store to persist
let storage = XyoInMemoryStorage()

// this is used as a place to store all of the bound witnesses/origin blocks
let chainRepo = XyoStorageOriginBlockRepository(storage: storage, hasher: hasher)

// this is used to save the state of the node (keys, index, previous hash)
let stateRepo = XyoStorageOriginChainStateRepository(storage: storage)

// this simply holds the state and the chain repository together
let configuration = XyoRepositoryConfiguration(originState: stateRepo, originBlock: chainRepo)

// the node to interface with creating an origin chain
let node = XyoOriginChainCreator(hasher: hasher, repositoryConfiguration: configuration)

```

After creating a node, it is standard to add a signer, and create a genesis block.

```swift
// creates a signer with a random private key
let signer = XyoSecp256k1Signer()
    
// adds the signer to the node
node.originState.addSigner(signer: signer)

// creates a origin block with its self (genesis block if this is the first block you make)
try node.selfSignOriginChain()

```

After creating a genesis block, your origin chain has officially started. Remember, all of the state is stored in the state repository (`XyoOriginChainStateRepository`) and the block repository (`XyoOriginBlockRepository`) that are constructed with the node. Both repositories are very high level and can be implemented for ones needs. Out of the box, this library comes with an implementation for key value store databases (`XyoStorageOriginBlockRepository`) and (`XyoStorageOriginChainStateRepository`). The `XyoStorageProvider` interface defines the methods for a simple key value store. There is a default implementation of an in memory key value store that comes with this library (`XyoInMemoryStorage`).


### Creating Origin Blocks

After a node has been created, it can be used to create origin blocks with other nodes. The process of talking to other nodes has been abstracted through use of a pipe (e.g. tcp, ble, memory) that handles all of the transport logic. This interface is defined as `XyoNetworkPipe`. This library ships with a memory pipe, and a tcp pipe.

**Using a tcp pipe** 

```swift
 // this defines who to create a tcp pipe with
let tcpPeer = XyoTcpPeer(ip: "myarchivist.com", port: 11000)

// prepares a socket tcp to communicate with the other node
let socket = XyoTcpSocket.create(peer: tcpPeer)

// wraps the socket to comply to the pipe interface
let pipe = XyoTcpSocketPipe(socket: socket, initiationData: nil)

// wraps the pipe to preform standard communications
let handler = XyoNetworkHandler(pipe: pipe)

node.boundWitness(handler: handler, procedureCatalogue: XyoProcedureCatalogue) { (boundWitness, error) in
    
}
```


**Using a memory pipe** 
```swift
let pipeOne = XyoMemoryPipe()
let pipeTwo = XyoMemoryPipe()

pipeOne.other = pipeTwo
pipeTwo.other = pipeOne

let handlerOne = XyoNetworkHandler(pipe: pipeOne)
let handlerTwo = XyoNetworkHandler(pipe: pipeTwo)

nodeOne.boundWitness(handler: handlerOne, procedureCatalogue: TestInteractionCatalogueCaseOne()) { (result, error) in
    // this should complete first
}

nodeTwo.boundWitness(handler: handlerTwo, procedureCatalogue: TestInteractionCatalogueCaseOne()) { (result, error) in
    // this should complete second
}
  ```
  More example and bridge interactions can be found [here](https://github.com/XYOracleNetwork/sdk-core-swift/tree/docs/sdk-core-swiftTests/node/interaction)
 
 
 **Bluetooth**
 
 Bluetooth swift pipes for client and server can be found [here](https://github.com/XYOracleNetwork/sdk-xyobleinterface-swift).
 
 
 **Other**
 
 Other network pipes can be implemented as long as the follow the interface defined [here](https://github.com/XYOracleNetwork/sdk-core-swift/blob/docs/sdk-core-swift/network/XyoNetworkPipe.swift).
 
 ### Adding custom data to bound witnesses.
 
 To add custum data to a bound witnesses, a XyoHueresticGetter can be created:
 
 ```swift
 public struct MyCustomData: XyoHueresticGetter {
    public func getHeuristic() -> XyoObjectStructure? {
        if (conditionIsMet) {
            let myData = getDataSomehow()
            return myData
        }
        
        return nil
    }
}
 ```
 
 After the getter has been created, it can be added to a node by calling:
 
 ```swift
 let myDataForBoundWitness = MyCustomData()
 node.addHuerestic (key: "MyData", getter : myDataForBoundWitness)
 
 ```
 
 
 ### Adding a listener to a node

```swift
 struct MyListener : XyoNodeListener {
    /// This function will be called every time a bound witness has started
    func onBoundWitnessStart() {
        // update UI
    }
    
    /// This function is called when a bound witness starts, but fails due to an error
    func onBoundWitnessEndFailure() {
        // update UI
    }
    
    /// This function is called when the node discovers a new origin block, this is typicaly its new blocks
    /// that it is creating, but will be called when a bridge discovers new blocks.
    /// - Parameter boundWitness: The boundwitness just discovered
    func onBoundWitnessDiscovered(boundWitness : XyoBoundWitness) {
     // update UI
    }
    
    /// This function is called every time a bound witness starts and complets successfully.
    /// - Parameter boundWitness: The boundwitness just completed
    func onBoundWitnessEndSuccess(boundWitness : XyoBoundWitness) {
        // update UI
    }
}
 ```
 
  You may add a listener to a node by adding the following:
  
  ```swift
  let listener = MyListener()
  myNode.addListener(key: "MyListener", listener : listener)
  
  ```



## License
This project is licensed under the MIT License - see the LICENSE.md file for details


<br><hr><br><p align="center">Made with  ❤️  by [**XY - The Persistent Company**](https://xy.company)</p>
