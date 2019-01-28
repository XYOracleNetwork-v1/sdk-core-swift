//
//  XyoOriginChainCreator.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

public class XyoOriginChainCreator {
    private let blockRepository : XyoOriginBlockRepository
    private let hasher : XyoHasher
    private var heuristics = [String : XyoHueresticGetter]()
    private var listeners = [String : XyoNodeListener]()
    private var boundWitnessOptions = [String : XyoBoundWitnessOption]()
    
    public let originState = XyoOriginChainState()
    
    struct XyoBoundWitnessHueresticPair {
        let unsignedPayload : [XyoObjectStructure]
        let signedPayload : [XyoObjectStructure]
        
        init (signedPayload: [XyoObjectStructure], unsignedPayload: [XyoObjectStructure]) {
            self.signedPayload = signedPayload
            self.unsignedPayload = unsignedPayload
        }
    }
    
    public init(hasher : XyoHasher, blockRepository : XyoOriginBlockRepository) {
        self.hasher = hasher
        self.blockRepository = blockRepository
    }
    
    public func addHuerestic (key: String, getter : XyoHueresticGetter) {
        heuristics[key] = getter
    }
    
    public func removeHuerestic (key: String) {
        heuristics.removeValue(forKey: key)
    }
    
    public func addListener (key: String, listener : XyoNodeListener) {
        listeners[key] = listener
    }
    
    public func removeLostener (key: String) {
        listeners.removeValue(forKey: key)
    }
    
    public func addBoundWitnessOption (key : String, option : XyoBoundWitnessOption) {
        boundWitnessOptions[key] = option
    }
    
    public func removeBoundWitnessOption (key: String) {
        boundWitnessOptions.removeValue(forKey: key)
    }
    
    public func selfSignOriginChain (flag : Int?) throws {
        let bitFlag = UInt(flag ?? 0)
        let options = getBoundWitneesesOptionsForFlag(flag: bitFlag)
        let optionPayloads = getBoundWitnessesOptions(options: options)
        let hueresticPayloads = getAllHuerestics()
        
        var signedAdditional = [XyoObjectStructure]()
        var unsignedAdditional = [XyoObjectStructure]()
        
        signedAdditional.append(contentsOf: optionPayloads.signedPayload)
        signedAdditional.append(contentsOf: hueresticPayloads.signedPayload)
        unsignedAdditional.append(contentsOf: optionPayloads.unsignedPayload)
        unsignedAdditional.append(contentsOf: hueresticPayloads.unsignedPayload)
        
        let boundWitness = try XyoZigZagBoundWitness(signers: originState.getSigners(),
                                                     signedPayload: try makeSignedPayload(additional: signedAdditional),
                                                     unsignedPayload: try makeSignedPayload(additional: unsignedAdditional))
        _ = try boundWitness.incomingData(transfer: nil, endpoint: true)
        
        try onBoundWitnessCompleted(boundWitness: boundWitness)
    }
    
    private func onBoundWitnessCompleted (boundWitness : XyoBoundWitness) throws {
        try updateOriginState(boundWitness: boundWitness)
        try unpackBoundWitness(boundWitness: boundWitness)
        
        for listener in listeners.values {
            listener.onBoundWitnessEndSuccess(boundWitness: boundWitness)
        }
    }
    
    private func unpackBoundWitness (boundWitness : XyoBoundWitness) throws {
        let hash = try boundWitness.getHash(hasher: hasher)
        
        if (!blockRepository.containsOriginBlock(originBlockHash: hash.getBuffer().toByteArray())) {
            let subblocks = try XyoOriginBoundWitnessUtil.getBridgeBlocks(boundWitness: boundWitness)
            let boundWitnessWithoughtSubBlocks = try XyoBoundWitnessUtil.removeIdFromUnsignedPayload(id: XyoSchemas.BRIDGE_BLOCK_SET.id,
                                                                                                     boundWitness: boundWitness)
            
            blockRepository.addOriginBlock(originBlock: boundWitnessWithoughtSubBlocks)
            
            for listener in listeners.values {
                listener.onBoundWitnessDiscovered(boundWitness: boundWitnessWithoughtSubBlocks)
            }
            
            if (subblocks != nil) {
                let it = try subblocks.unsafelyUnwrapped.getNewIterator()
                
                while (try it.hasNext()) {
                    try unpackBoundWitness(boundWitness: XyoBoundWitness(value: try it.next().getBuffer()))
                }
            }
        }
    }
    
    private func updateOriginState (boundWitness : XyoBoundWitness) throws {
        let hash = try boundWitness.getHash(hasher: hasher)
        originState.addOriginBlock(hash: hash)
    }
    
    private func getAllHuerestics () -> XyoBoundWitnessHueresticPair {
        var returnHuerestics = [XyoObjectStructure]()
        
        for getter in heuristics.values {
            let huerestic = getter.getHeuristic()
            
            if (huerestic != nil) {
                returnHuerestics.append(huerestic.unsafelyUnwrapped)
            }
        }
        
        return XyoBoundWitnessHueresticPair(signedPayload: returnHuerestics, unsignedPayload: [])
    }
    
    private func makeSignedPayload (additional : [XyoObjectStructure]) throws -> [XyoObjectStructure] {
        var signedPayload = additional
        let previousHash = try originState.getPreviousHash()
        let index = originState.getIndex()
        let nextPublicKey = originState.getNextPublicKey()
        
        if (previousHash != nil) {
            signedPayload.append(previousHash.unsafelyUnwrapped)
        }
        
        if (nextPublicKey != nil) {
            signedPayload.append(nextPublicKey.unsafelyUnwrapped)
        }
        
        signedPayload.append(index)
        
        return signedPayload
    }
    
    
    private func getBoundWitneesesOptionsForFlag (flag : UInt) -> [XyoBoundWitnessOption] {
        var retunOptions = [XyoBoundWitnessOption]()
        
        for option in boundWitnessOptions.values {
            if (flag & option.getFlag() != 0) {
                retunOptions.append(option)
            }
        }
        
        return retunOptions
    }
    
    private func getBoundWitnessesOptions (options : [XyoBoundWitnessOption]) -> XyoBoundWitnessHueresticPair {
        var signedPayloads = [XyoObjectStructure]()
        var unsignedPayloads = [XyoObjectStructure]()
        
        for option in options {
            let unsignedPayload = option.getUnsignedPatload()
            let signedPayload = option.getSignedPayload()
            
            if (unsignedPayload != nil) {
                unsignedPayloads.append(unsignedPayload.unsafelyUnwrapped)
            }
            
            if (signedPayload != nil) {
                signedPayloads.append(signedPayload.unsafelyUnwrapped)
            }
        }
        
        return XyoBoundWitnessHueresticPair(signedPayload: signedPayloads, unsignedPayload: unsignedPayloads)
    }
}
