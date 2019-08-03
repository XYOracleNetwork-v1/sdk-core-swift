[logo]: https://cdn.xy.company/img/brand/XY_Logo_GitHub.png

[![logo]](https://xy.company)

# sdk-core-swift

[![Maintainability](https://api.codeclimate.com/v1/badges/587ae96e86057b6b6178/maintainability)](https://codeclimate.com/repos/5c4a7a7372b7b2029d008b34/maintainability) [![](https://img.shields.io/cocoapods/v/sdk-core-swift.svg?style=flat)](https://cocoapods.org/pods/sdk-core-swift) [![Test Coverage](https://api.codeclimate.com/v1/badges/587ae96e86057b6b6178/test_coverage)](https://codeclimate.com/repos/5c4a7a7372b7b2029d008b34/test_coverage)


| Branches        | Status           |
| ------------- |:-------------:|
| Master      | [![Build Status](https://travis-ci.org/XYOracleNetwork/sdk-core-swift.svg?branch=master)](https://travis-ci.org/XYOracleNetwork/sdk-core-swift) |
| Develop      | [![Build Status](https://travis-ci.org/XYOracleNetwork/sdk-core-swift.svg?branch=develop)](https://travis-ci.org/XYOracleNetwork/sdk-core-swift)      |



A library to preform all core XYO Network functions.
This includes; creating an origin chain, maintaining an origin chain, negotiations for talking to other nodes, and other basic functionality.
The library has heavily abstracted modules so that all operations will work with any crypto, storage, networking, etc.

The XYO protocol for creating origin-blocks is specified in the [XYO Yellow Paper](https://docs.xyo.network/XYO-Yellow-Paper.pdf). In it, it describes the behavior of how a node on the XYO network should create Bound Witnesses. Note, the behavior is not coupled with any particular technology constraints around transport layers, cryptographic algorithms, or hashing algorithms.

[Here](https://github.com/XYOracleNetwork/spec-coreobjectmodel-tex) is a link to the core object model that contains an index of major/minor values and their respective objects.


## License
This project is licensed under the GNU License - see the LICENSE.md file for details


<br><hr><br><p align="center">Made with  ❤️  by [**XY - The Persistent Company**](https://xy.company)</p>
