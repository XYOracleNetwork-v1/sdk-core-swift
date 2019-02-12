//
//  XyoRelayNode.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

open class XyoRelayNode : XyoOriginChainCreator, XyoNodeListener {
    private static let LISTENER_KEY = "RELAY_NODE"
    private static let OPTION_KEY = "BRIDING_OPTION"
    
    public let blocksToBridge = XyoBridgeQueue()
    private let bridgeOption : XyoBridgingOption
    
    public override init(hasher: XyoHasher, blockRepository: XyoOriginBlockRepository) {
        bridgeOption = XyoBridgingOption(bridgeQueue: blocksToBridge, originBlockRepository: blockRepository)
        super.init(hasher: hasher, blockRepository: blockRepository)
        
        addListener(key: XyoRelayNode.LISTENER_KEY, listener: self)
        addBoundWitnessOption(key: XyoRelayNode.OPTION_KEY, option: bridgeOption)
    }
    

    public func onBoundWitnessDiscovered(boundWitness : XyoBoundWitness) {
        for hash in blocksToBridge.getBlocksToRemove() {
            do {
                try blockRepository.removeOriginBlock(originBlockHash: hash.getBuffer().toByteArray())
            } catch {
                // todo handle error on removal
            }
        }
    }
    
    public func onBoundWitnessEndSuccess(boundWitness : XyoBoundWitness) {
        do {
            blocksToBridge.addBlock(blockHash: try boundWitness.getHash(hasher: hasher))
        } catch {
            // do not add block to queue if there is an issue with getting its hash
        }
    }
    
    public func onBoundWitnessEndFailure() { }
    public func onBoundWitnessStart() {}
}
