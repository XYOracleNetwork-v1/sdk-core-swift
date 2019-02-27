
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
            let storage = XyoInMemoryStorage()
            let node = XyoRelayNode(hasher: XyoSha256(),
                                    blockRepository: XyoStrageProviderOriginBlockRepository(storageProvider: storage,
                                                                                            hasher: XyoSha256()),
                                    originStateRepository: XyoStorageOriginChainStateRepository(storage: storage),
                                    queueRepository: XyoStorageBridgeQueueRepository(storage: storage))
            
            node.originState.addSigner(signer: XyoSecp256k1Signer())

            while (true) {
                let peer = XyoTcpPeer(ip: "localhost", port: 11000)
                let socket = XyoTcpSocket.create(peer: peer)
                let pipe = XyoTcpSocketPipe(socket: socket, initiationData: nil)
                let handler = XyoNetworkHandler(pipe: pipe)

                _ = try node.doNeogeoationThenBoundWitness(handler: handler, procedureCatalogue: XyoFlagProcedureCatalogue(forOther: 0xff, withOther: 0xff))
            }
        }
    }
    
}


