//
//  XyoStandardInteractionTest.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 4/8/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
import sdk_objectmodel_swift
@testable import sdk_core_swift

class XyoStandardInteractionTest: XCTestCase {
    
    func testStandardInteractionCaseOne () {
        let nodeOne = createNewRelayNode()
        let nodeTwo = createNewRelayNode()
        
        let pipeOne = XyoMemoryPipe()
        let pipeTwo = XyoMemoryPipe()
        
        pipeOne.other = pipeTwo
        pipeTwo.other = pipeOne
        
        let handlerOne = XyoNetworkHandler(pipe: pipeOne)
        let handlerTwo = XyoNetworkHandler(pipe: pipeTwo)
        
        let nodeOneCompletionOne = expectation(description: "Node one should finish bound witness.")
        let nodeTwoCompletionOne = expectation(description: "Node two should finish bound witness.")
        
        nodeOne.boundWitness(handler: handlerOne, procedureCatalogue: TestInteractionCatalogueCaseOne()) { (result, error) in
            // this should complete first
            XCTAssertNil(error, "There should be no error from node one")
            XCTAssertNil(getFetterItem(boundWitness: result!, itemId: XyoSchemas.BRIDGE_HASH_SET.id, partyIndex: 0))
            XCTAssertTrue(correctIndex(boundWitness: result!, partyIndex: 0, indexNum: 1))
            nodeOneCompletionOne.fulfill()
        }
        
        nodeTwo.boundWitness(handler: handlerTwo, procedureCatalogue: TestInteractionCatalogueCaseOne()) { (result, error) in
             // this should complete second
            XCTAssertNil(error, "There should be no error from node one")
            XCTAssertNil(getFetterItem(boundWitness: result!, itemId: XyoSchemas.BRIDGE_HASH_SET.id, partyIndex: 0))
            XCTAssertTrue(correctIndex(boundWitness: result!, partyIndex: 1, indexNum: 1))
            nodeTwoCompletionOne.fulfill()
        }
        
        wait(for: [nodeOneCompletionOne, nodeTwoCompletionOne], timeout: 1)
    }
    
    
    private func createNewRelayNode () -> XyoRelayNode {
        do {
            let storage = XyoInMemoryStorage()
            let blocks = XyoStrageProviderOriginBlockRepository(storageProvider: storage,hasher: XyoSha256())
            let state = XyoStorageOriginChainStateRepository(storage: storage)
            let conf = XyoRepositoryConfiguration(originState: state, originBlock: blocks)
            
            let node = XyoRelayNode(hasher: XyoSha256(),
                                    repositoryConfiguration: conf,
                                    queueRepository: XyoStorageBridgeQueueRepository(storage: storage))
            
            try node.selfSignOriginChain()
            
            return node
        } catch {
            fatalError("Node should be able to sign its chain")
        }
    }
    
}
