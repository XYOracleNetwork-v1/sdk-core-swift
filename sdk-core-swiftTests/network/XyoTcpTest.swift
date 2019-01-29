
//
//  TcpTest.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 1/29/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
import sdk_objectmodel_swift
@testable import sdk_core_swift

class XyoTcpSocketTest : XCTestCase {
    
    func testClient () {
        let tcp = XyoTcpSocket.create(ip: "127.0.0.1", port: 8889)
        tcp.openReadStream()
        tcp.openWriteStream()
        print(tcp.read(size: 5, canBlock: true))
        print(tcp.write(bytes: [100, 100]))
    }
    
}
