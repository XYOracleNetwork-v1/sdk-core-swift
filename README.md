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

// creates a origin block with its self (genesis block if this is the first block you male)
try node.selfSignOriginChain()

```


## License
This project is licensed under the MIT License - see the LICENSE.md file for details


<br><hr><br><p align="center">Made with  ❤️  by [**XY - The Persistent Company**](https://xy.company)</p>
