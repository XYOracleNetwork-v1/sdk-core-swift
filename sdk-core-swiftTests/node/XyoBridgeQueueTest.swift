//
//  XyoBridgeQueueTest.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
import sdk_objectmodel_swift
@testable import sdk_core_swift

class XyoBridgeQueueTest: XCTestCase {
    
    func testBridgeQueueWhenRemoveWeightIsSmallerThanSendSize () throws {
        let queue = XyoBridgeQueue()
        let numberOfBlocks = 1000
        var numberOfBlocksOffloaded = 0
        var payloadsSent = 0
        queue.removeWeight = 3
        queue.sendLimit = 10
        
        for _ in 0...numberOfBlocks - 1 {
            queue.addBlock(blockHash: XyoObjectStructure.newInstance(schema: XyoSchemas.STUB_HASH, bytes: XyoBuffer(data: [UInt8(0x00)])))
        }
        
        while queue.blocksToBridge.count > 0 {
            let blocksToBridge = queue.getBlocksToBridge()
            payloadsSent += 1
            numberOfBlocksOffloaded += blocksToBridge.count
            
            for i in 0...blocksToBridge.count - 1 {
                blocksToBridge[i].bridged()
            }
            
            _ = queue.getBlocksToRemove()
        }
        
        XCTAssertEqual(queue.removeWeight * numberOfBlocks, numberOfBlocksOffloaded)
        XCTAssertEqual((numberOfBlocks / queue.sendLimit) * queue.removeWeight, payloadsSent)
    }
    
}
