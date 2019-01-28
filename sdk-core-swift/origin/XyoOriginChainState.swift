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
    private var currentSigners : [XyoSigner] = []
    private var waitingSigners : [XyoSigner] = []
    private var nextPublicKey : XyoObjectStructure? = nil
    private var latestHash : XyoObjectStructure? = nil
    private var count : Int = 0
    private let indexOffset : Int
    
    public init() {
        self.indexOffset = 0
    }
    
    public init (indexOffset : Int) {
        self.indexOffset = indexOffset
    }
    
    public func getIndex () -> XyoObjectStructure {
        let buffer = XyoBuffer()
        buffer.put(bits: UInt32(count + indexOffset))
        return XyoObjectStructure.newInstance(schema: XyoSchemas.INDEX, bytes: buffer)
    }
    
    public func getPreviousHash () throws -> XyoObjectStructure? {
        guard let hashValue = latestHash else {
            return nil
        }
        
        return try XyoIterableStructure.createTypedIterableObject(schema: XyoSchemas.PREVIOUS_HASH, values: [hashValue])
    }
    
    public func getSigners () -> [XyoSigner] {
        return currentSigners
    }
    
    public func getNextPublicKey () -> XyoObjectStructure? {
        return nextPublicKey
    }
    
    public func addSigner (signer : XyoSigner) {
        if ((count + indexOffset) == 0) {
            currentSigners.append(signer)
            return
        }
        
        nextPublicKey = XyoObjectStructure.newInstance(schema: XyoSchemas.NEXT_PUBLIC_KEY, bytes: signer.getPublicKey().getBuffer())
        waitingSigners.append(signer)
    }
    
    public func removeOldestSigner () {
        currentSigners.remove(at: 0)
    }
    
    public func addOriginBlock (hash : XyoObjectStructure) {
        nextPublicKey = nil
        latestHash = hash
        addWaitingSigner()
        count += 1
    }
    
    private func addWaitingSigner () {
        if (waitingSigners.count > 0) {
            currentSigners.append(waitingSigners[0])
            waitingSigners.remove(at: 0)
        }
    }
}
