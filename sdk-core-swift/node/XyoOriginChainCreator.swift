//
//  XyoOriginChainCreator.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

open class XyoOriginChainCreator {
    public let blockRepository : XyoOriginBlockRepository
    let hasher : XyoHasher
    private var heuristics = [String : XyoHueresticGetter]()
    private var listeners = [String : XyoNodeListener]()
    private var boundWitnessOptions = [String : XyoBoundWitnessOption]()
    private var currentBoundWitnessSession : XyoZigZagBoundWitnessSession? = nil
    
    public let originState = XyoOriginChainState()
    
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
        if (currentBoundWitnessSession == nil) {
            let bitFlag = UInt(flag ?? 0)
            let additional = try getAdditionalPayloads(flag: bitFlag)
            
            onBoundWitnessStart()
            let boundWitness = try XyoZigZagBoundWitness(signers: originState.getSigners(),
                                                         signedPayload: try makeSignedPayload(additional: additional.signedPayload),
                                                         unsignedPayload: additional.unsignedPayload)
            _ = try boundWitness.incomingData(transfer: nil, endpoint: true)
            
            try onBoundWitnessCompleted(boundWitness: boundWitness)
            return
        }
        
        throw XyoError.BW_IS_IN_PROGRESS
    }
    
    public func doBoundWitnessWithPipe (startingData : XyoIterableStructure?, pipe : XyoNetworkPipe, choice : UInt32) throws {
        if (currentBoundWitnessSession != nil) {
            throw XyoError.BW_IS_IN_PROGRESS
        }
        
        let additional = try getAdditionalPayloads(flag: UInt(choice))
        
        onBoundWitnessStart()
        let boundWitness = try XyoZigZagBoundWitnessSession(signers: originState.getSigners(),
                                                            signedPayload: try makeSignedPayload(additional: additional.signedPayload),
                                                            unsignedPayload: additional.unsignedPayload,
                                                            pipe: pipe,
                                                            choice: XyoBuffer().put(bits: choice).toByteArray())
        
        currentBoundWitnessSession = boundWitness
        
        do {
            try boundWitness.doBoundWitness(transfer: startingData)
            
            if (try boundWitness.getIsCompleted() == true) {
                try onBoundWitnessCompleted(boundWitness: boundWitness)
            }
        } catch is XyoError {
            onBoundWitnessFailure()
        } catch is XyoObjectError {
            onBoundWitnessFailure()
        }
        
        pipe.close()
        currentBoundWitnessSession = nil
    }
    
    private func onBoundWitnessStart () {
        for listener in listeners.values {
            listener.onBoundWitnessStart()
        }
    }
    
    private func onBoundWitnessFailure () {
        for listener in listeners.values {
            listener.onBoundWitnessEndFailure()
        }
    }
    
    private func onBoundWitnessCompleted (boundWitness : XyoBoundWitness) throws {
        try updateOriginState(boundWitness: boundWitness)
        try unpackBoundWitness(boundWitness: boundWitness)
        
        for listener in listeners.values {
            listener.onBoundWitnessEndSuccess(boundWitness: boundWitness)
        }
    }
    
    private func getAdditionalPayloads (flag : UInt) throws -> XyoBoundWitnessHueresticPair {
        let options = getBoundWitneesesOptionsForFlag(flag: flag)
        let optionPayloads = try getBoundWitnessesOptions(options: options)
        let hueresticPayloads = getAllHuerestics()
        
        var signedAdditional = [XyoObjectStructure]()
        var unsignedAdditional = [XyoObjectStructure]()
        
        signedAdditional.append(contentsOf: optionPayloads.signedPayload)
        signedAdditional.append(contentsOf: hueresticPayloads.signedPayload)
        unsignedAdditional.append(contentsOf: optionPayloads.unsignedPayload)
        unsignedAdditional.append(contentsOf: hueresticPayloads.unsignedPayload)
        
        return XyoBoundWitnessHueresticPair(signedPayload: signedAdditional, unsignedPayload: unsignedAdditional)
    }
    
    private func unpackBoundWitness (boundWitness : XyoBoundWitness) throws {
        let hash = try boundWitness.getHash(hasher: hasher)
        
        if (try !blockRepository.containsOriginBlock(originBlockHash: hash.getBuffer().toByteArray())) {
            try unpackNewBoundWitness(boundWitness: boundWitness)
        }
    }
    
    private func unpackNewBoundWitness (boundWitness : XyoBoundWitness) throws {
        let subblocks = try XyoOriginBoundWitnessUtil.getBridgeBlocks(boundWitness: boundWitness)
        let boundWitnessWithoughtSubBlocks = try XyoBoundWitnessUtil.removeIdFromUnsignedPayload(id: XyoSchemas.BRIDGE_BLOCK_SET.id,
                                                                                                 boundWitness: boundWitness)
        
        try blockRepository.addOriginBlock(originBlock: boundWitnessWithoughtSubBlocks)
        
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
    
    private func getBoundWitnessesOptions (options : [XyoBoundWitnessOption]) throws -> XyoBoundWitnessHueresticPair {
        var signedPayloads = [XyoObjectStructure]()
        var unsignedPayloads = [XyoObjectStructure]()
        
        for option in options {
            let pair = try option.getPair()
            
            if (pair != nil) {
                signedPayloads.append(contentsOf: pair.unsafelyUnwrapped.signedPayload)
                unsignedPayloads.append(contentsOf: pair.unsafelyUnwrapped.unsignedPayload)
            }
        }
        
        return XyoBoundWitnessHueresticPair(signedPayload: signedPayloads, unsignedPayload: unsignedPayloads)
    }
}