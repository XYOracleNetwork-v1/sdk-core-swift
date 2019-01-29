//
//  XyoBridgeQueue.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

public class XyoBridgeQueue {
    public var sendLimit = 10
    public var removeWeight = 3
    public var blocksToBridge = [XyoBridgeQueueItem]()
    
    func addBlock (blockHash : XyoObjectStructure) {
        addBlock(blockHash: blockHash, weight: 0)
    }
    
    func addBlock (blockHash : XyoObjectStructure, weight : Int) {
        blocksToBridge.append(XyoBridgeQueueItem(weight: weight, hash: blockHash))
    }
    
    func getBlocksToBridge() -> [XyoBridgeQueueItem] {
        var toBrigde = [XyoBridgeQueueItem]()
        
        blocksToBridge.sort {
            $0.weight > $1.weight
        }
        
        for i in 0..<min(blocksToBridge.count, sendLimit) {
            toBrigde.append(blocksToBridge[i])
        }
        
        return toBrigde
    }
    
    func getBlocksToRemove () -> [XyoObjectStructure] {
        var toRemoveHashes = [XyoObjectStructure]()
        
        for i in (0..<blocksToBridge.count).reversed() {
            if (blocksToBridge[i].weight >= removeWeight) {
                toRemoveHashes.append(blocksToBridge[i].hash)
                blocksToBridge.remove(at: i)
            }
        }
        
        return toRemoveHashes
    }
}
