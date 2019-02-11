
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
    
    func testClient () throws {
        if (false) {
            // this test must be run manualy
            let node = XyoRelayNode(hasher: XyoSha256(), blockRepository: try XyoStrageProviderOriginBlockRepository(storageProvider: XyoInMemoryStorage(), hasher: XyoSha256()))
            node.originState.addSigner(signer: XyoStubSigner())
            
            while (true) {
                
                let socket = XyoTcpSocket.create(ip: "localhost", port: 1111)
                let pipe = XyoTcpSocketPipe(socket: socket, initiationData: nil)
                let handler = XyoNetworkHandler(pipe: pipe)
                
                _ = try node.doNeogeoationThenBoundWitness(handler: handler, procedureCatalogue: XyoFlagProcedureCatalogue(forOther: 0xff, withOther: 0xff))
            }
        }
    }
    
}
