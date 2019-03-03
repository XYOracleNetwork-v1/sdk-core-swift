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
    public let repositoryConfiguration : XyoRepositoryConfiguration
    public let hasher : XyoHasher
    
    private var heuristics = [String : XyoHueresticGetter]()
    private var listeners = [String : XyoNodeListener]()
    private var boundWitnessOptions = [String : XyoBoundWitnessOption]()
    private var currentBoundWitnessSession : XyoZigZagBoundWitnessSession? = nil
    
    public lazy var originState = XyoOriginChainState(repository: self.repositoryConfiguration.originState)
    
    public init(hasher : XyoHasher, repositoryConfiguration: XyoRepositoryConfiguration) {
        self.hasher = hasher
        self.repositoryConfiguration = repositoryConfiguration
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
    
    
    public func selfSignOriginChain () throws {
        if (currentBoundWitnessSession == nil) {
            let additional = try getAdditionalPayloads(flag: [])
            
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
    
    public func boundWitness (handler : XyoNetworkHandler, procedureCatalogue: XyoProcedureCatalogue, completion: @escaping (_: XyoBoundWitness?, _: XyoError?)->()) {
        if (currentBoundWitnessSession != nil) {
            completion(nil, XyoError.BW_IS_IN_PROGRESS)
            return
        }
        
        onBoundWitnessStart()
        
        if (handler.pipe.getInitiationData() == nil) {
            // is client
            
            // send first neogeoation, response is their choice
            handler.sendCataloguePacket(catalogue: procedureCatalogue.getEncodedCatalogue()) { result in
                guard let responseWithTheirChoice = result else {
                    self.onBoundWitnessFailure()
                    return
                }
                
                let adv = XyoChoicePacket(data: responseWithTheirChoice)
                let startingData = XyoIterableStructure(value: XyoBuffer(data: adv.getResponce()))
                self.doBoundWitnessWithPipe(startingData: startingData, handler: handler, choice: adv.getChoice(), completion: completion)
            }
            return
        }
        
        // is server, initation data is the clients catalogue, so we must choose one
        let choice = procedureCatalogue.choose(catalogue: handler.pipe.getInitiationData().unsafelyUnwrapped.getChoice())
        doBoundWitnessWithPipe(startingData: nil, handler: handler, choice: choice, completion: completion)
    }
    
    private func doBoundWitnessWithPipe (startingData : XyoIterableStructure?, handler : XyoNetworkHandler, choice : [UInt8], completion: @escaping (_: XyoBoundWitness?, _: XyoError?)->()) {
    
        do {
            
            let options = getBoundWitneesesOptionsForFlag(flag: [UInt8(XyoProcedureCatalogueFlags.GIVE_ORIGIN_CHAIN)])
            let additional = try getAdditionalPayloads(flag: [UInt8(XyoProcedureCatalogueFlags.GIVE_ORIGIN_CHAIN)])
            
            let boundWitness = try XyoZigZagBoundWitnessSession(signers: originState.getSigners(),
                                                                signedPayload: try makeSignedPayload(additional: additional.signedPayload),
                                                                unsignedPayload: additional.unsignedPayload,
                                                                handler: handler,
                                                                choice: choice)
            
            currentBoundWitnessSession = boundWitness
            
            boundWitness.doBoundWitness(transfer: startingData) { result in
            
                do {
                    if (try boundWitness.getIsCompleted() == true) {
                        
                        if (options.count > 0) {
                            for i in 0...options.count - 1 {
                                options[i].onCompleted(boundWitness: boundWitness)
                            }
                        }
                        
                        try self.onBoundWitnessCompleted(boundWitness: boundWitness)
                    }
                    
                    self.currentBoundWitnessSession = nil
                    completion(boundWitness, nil)
                } catch {
                    self.onBoundWitnessFailure()
                    handler.pipe.close()
                    self.currentBoundWitnessSession = nil
                    completion(nil, XyoError.UNKNOWN_ERROR)
                }
                
                return nil
            }
            
            
        } catch {
            onBoundWitnessFailure()
            handler.pipe.close()
            currentBoundWitnessSession = nil
            completion(nil, XyoError.UNKNOWN_ERROR)
        }
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
    
    private func getAdditionalPayloads (flag : [UInt8]) throws -> XyoBoundWitnessHueresticPair {
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

        if (try !repositoryConfiguration.originBlock.containsOriginBlock(originBlockHash: hash.getBuffer().toByteArray())) {
            try unpackNewBoundWitness(boundWitness: boundWitness)
        }
    }
    
    private func unpackNewBoundWitness (boundWitness : XyoBoundWitness) throws {
        let subblocks = try XyoOriginBoundWitnessUtil.getBridgeBlocks(boundWitness: boundWitness)
        let boundWitnessWithoughtSubBlocks = try XyoBoundWitnessUtil.removeIdFromUnsignedPayload(id: XyoSchemas.BRIDGE_BLOCK_SET.id,
                                                                                                 boundWitness: boundWitness)
        try repositoryConfiguration.originBlock.addOriginBlock(originBlock: boundWitnessWithoughtSubBlocks)
        
        for listener in listeners.values {
            listener.onBoundWitnessDiscovered(boundWitness: boundWitnessWithoughtSubBlocks)
        }
        
        if (subblocks != nil) {
            let it = try subblocks.unsafelyUnwrapped.getNewIterator()
            
            while (try it.hasNext()) {
                let item = try it.next().getBuffer()
                try unpackBoundWitness(boundWitness: XyoBoundWitness(value: item))
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
        let previousHash = originState.getPreviousHash()
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
    
    
    private func getBoundWitneesesOptionsForFlag (flag : [UInt8]) -> [XyoBoundWitnessOption] {
        var retunOptions = [XyoBoundWitnessOption]()
        
        for option in boundWitnessOptions.values {
            if (min(option.getFlag().count, flag.count) != 0) {
                for i in 0...(min(option.getFlag().count, flag.count) - 1) {
                    let otherCatalogueSection = option.getFlag()[option.getFlag().count - i - 1]
                    let thisCatalogueSection = flag[flag.count - i - 1]
                    
                    if (otherCatalogueSection & thisCatalogueSection != 0) {
                        retunOptions.append(option)
                    }
                }
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
