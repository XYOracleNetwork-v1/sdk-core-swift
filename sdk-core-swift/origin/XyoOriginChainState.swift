//
//  XyoOriginChainState.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift


public class XyoOriginChainState {
    let repo : XyoOriginChainStateRepository
    private var waitingSigners : [XyoSigner] = []
    private var nextPublicKey : XyoObjectStructure? = nil
    
    public init(repository : XyoOriginChainStateRepository) {
        self.repo = repository
    }

    public func getIndex () -> XyoObjectStructure {
        return repo.getIndex() ?? XyoOriginChainState.createIndex(index: 0)
    }
    
    public func getPreviousHash () -> XyoObjectStructure? {
        return repo.getPreviousHash()
    }
    
    public func getSigners () -> [XyoSigner] {
        return repo.getSigners()
    }
    
    public func getNextPublicKey () -> XyoObjectStructure? {
        return nextPublicKey
    }
    
    public func removeOldestSigner () {
        repo.removeOldestSigner()
    }
    
    public func addSigner (signer : XyoSigner) {
        do {
            let index = try getIndex().getValueCopy().getUInt32(offset: 0)
            
            if (index == 0) {
                repo.putSigner(signer: signer)
                return
            }
        } catch {
            fatalError("Index should be parcable.")
        }
        
        waitingSigners.append(signer)
        nextPublicKey = XyoOriginChainState.createNextPublicKey(publicKey: signer.getPublicKey())
    }
    
    public func addOriginBlock (hash : XyoObjectStructure) {
        nextPublicKey = nil
        addWaitingSigner()
        repo.putPreviousHash(hash: hash)
        incrementIndex()
    }
    
    private func incrementIndex () {
        do {
            let index = try getIndex().getValueCopy().getUInt32(offset: 0)
            let awaitingIndex = XyoOriginChainState.createIndex(index: index + 1)
            repo.putIndex(index: awaitingIndex)
        } catch {
            fatalError("Index provided is invalid.")
        }
    }
    
    private func addWaitingSigner () {
        if (waitingSigners.count > 0) {
            repo.putSigner(signer: waitingSigners[0])
            waitingSigners.remove(at: 0)
        }
    }
    
    public static func createIndex (index : UInt32) -> XyoObjectStructure {
        let buffer = XyoBuffer()
        buffer.put(bits: index)
        return XyoObjectStructure.newInstance(schema: XyoSchemas.INDEX, bytes: buffer)
    }
    
    public static func createPreviousHash (hash : XyoIterableStructure) throws -> XyoObjectStructure {
        return try XyoIterableStructure.createTypedIterableObject(schema: XyoSchemas.PREVIOUS_HASH, values: [hash])
    }
    
    public static func createNextPublicKey (publicKey : XyoObjectStructure) -> XyoObjectStructure {
        return XyoObjectStructure.newInstance(schema: XyoSchemas.NEXT_PUBLIC_KEY, bytes: publicKey.getBuffer())
    }
}
