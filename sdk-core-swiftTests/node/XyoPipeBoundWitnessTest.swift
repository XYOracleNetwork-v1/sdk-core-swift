//
//  XyoPipeBoundWitnessTest.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 3/3/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
import sdk_objectmodel_swift
@testable import sdk_core_swift

class XyoPipeBoundWitnessTest: XCTestCase {
    let allProcedureCatalohue = XyoFlagProcedureCatalogue(forOther: 0xff, withOther: 0xff)
    
    func testPipeBoundWitness () {
        let nodeOne = createNewRelayNode()
        let nodeTwo = createNewRelayNode()
        
        let pipeOne = XyoMemoryPipe()
        let pipeTwo = XyoMemoryPipe()
        
        pipeOne.other = pipeTwo
        pipeTwo.other = pipeOne
        
        let handlerOne = XyoNetworkHandler(pipe: pipeOne)
        let handlerTwo = XyoNetworkHandler(pipe: pipeTwo)
        
        let nodeOneCompletion = expectation(description: "Node one should finish bound witness.")
        let nodeTwoCompletion = expectation(description: "Node two should finish bound witness.")

        
        nodeOne.boundWitness(handler: handlerOne, procedureCatalogue: allProcedureCatalohue) { (result, error) in
            XCTAssertNil(error)
            nodeOneCompletion.fulfill()
        }
        
        nodeTwo.boundWitness(handler: handlerTwo, procedureCatalogue: allProcedureCatalohue) { (result, error) in
            XCTAssertNil(error)
            nodeTwoCompletion.fulfill()
        }
        
        wait(for: [nodeOneCompletion, nodeTwoCompletion], timeout: 1)
    }
    
    private func createNewRelayNode () -> XyoRelayNode {
        let storage = XyoInMemoryStorage()
        let blocks = XyoStrageProviderOriginBlockRepository(storageProvider: storage,
                                                            hasher: XyoSha256())
        let state = XyoStorageOriginChainStateRepository(storage: storage)
        let conf = XyoRepositoryConfiguration(originState: state, originBlock: blocks)
        return XyoRelayNode(hasher: XyoSha256(),
                            repositoryConfiguration: conf,
                            queueRepository: XyoStorageBridgeQueueRepository(storage: storage))
    }
}

