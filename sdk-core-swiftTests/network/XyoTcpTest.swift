
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
            // true test must be run manualy
            let storage = XyoInMemoryStorage()
            let blocks = XyoStrageProviderOriginBlockRepository(storageProvider: storage,
                                                                hasher: XyoSha256())
            let state = XyoStorageOriginChainStateRepository(storage: storage)
            let conf = XyoRepositoryConfiguration(originState: state, originBlock: blocks)
            let node = XyoRelayNode(hasher: XyoSha256(),
                                    repositoryConfiguration: conf,
                                    queueRepository: XyoStorageBridgeQueueRepository(storage: storage))
            
            node.originState.addSigner(signer: XyoSecp256k1Signer())

            while (true) {
                let peer = XyoTcpPeer(ip: "localhost", port: 11000)
                let socket = XyoTcpSocket.create(peer: peer)
                let pipe = XyoTcpSocketPipe(socket: socket, initiationData: nil)
                let handler = XyoNetworkHandler(pipe: pipe)

                node.boundWitness(handler: handler, procedureCatalogue: XyoFlagProcedureCatalogue(forOther: 0xff, withOther: 0xff)) { (result, error) in
                        
                }
            }
        }
    }
}


