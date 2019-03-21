//
//  XyoStorageOriginChainStateRepository.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 2/26/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

public class XyoStorageOriginChainStateRepository: XyoOriginChainStateRepository {
    private var signersCache = [XyoSigner]()
    private var statics : [XyoObjectStructure] = []
    private var indexCache : XyoObjectStructure? = nil
    private var previousHashCache : XyoObjectStructure? = nil
    
    private let store : XyoStorageProvider
    private static let ORIGIN_STATE_INDEX_KEY = Array("ORIGIN_STATE_INDEX_KEY".utf8)
    private static let ORIGIN_HASH_INDEX_KEY = Array("ORIGIN_HASH_INDEX_KEY".utf8)
    private static let ORIGIN_STATTICS_KEY = Array("ORIGIN_STATICS_KEY".utf8)
    
    public init(storage : XyoStorageProvider) {
        self.store = storage
    }
    
    public func getIndex() -> XyoObjectStructure? {
        return indexCache
    }
    
    public func putIndex(index: XyoObjectStructure) {
        indexCache = index
    }
    
    public func getPreviousHash() -> XyoObjectStructure? {
        return previousHashCache
    }
    
    public func putPreviousHash(hash: XyoObjectStructure) {
        previousHashCache = hash
    }
    
    public func getSigners() -> [XyoSigner] {
        return signersCache
    }
    
    public func setStaticHuerestics(huerestics: [XyoObjectStructure]) {
        self.statics = huerestics
    }
    
    public func getStaticHuerestics() -> [XyoObjectStructure] {
        return statics
    }
    
    public func removeOldestSigner() {
        if (signersCache.count > 0) {
            signersCache.removeFirst()
        }
    }
    
    public func putSigner(signer: XyoSigner) {
        signersCache.append(signer)
    }
    
    public func commit () {
        do {
            
            let encodedStatics = XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.ARRAY_UNTYPED, values: self.statics)
                .getBuffer()
                .toByteArray()
            
            try store.write(key: XyoStorageOriginChainStateRepository.ORIGIN_STATTICS_KEY, value: encodedStatics)
            
            if (indexCache != nil) {
                let encodedIndex = indexCache!.getBuffer().toByteArray()
                try store.write(key: XyoStorageOriginChainStateRepository.ORIGIN_STATE_INDEX_KEY, value: encodedIndex)
            }
            
            if (previousHashCache != nil) {
                let encodedHash = previousHashCache!.getBuffer().toByteArray()
                try store.write(key: XyoStorageOriginChainStateRepository.ORIGIN_HASH_INDEX_KEY, value: encodedHash)
            }
        } catch {
            // todo handle error
        }
        
    }
    
    public func restoreState (signers : [XyoSigner]) {
        do {
            signersCache = signers
            
            guard let encodedIndex = try store.read(key: XyoStorageOriginChainStateRepository.ORIGIN_STATE_INDEX_KEY) else {
                return
            }
            
            guard let encodedHash = try store.read(key: XyoStorageOriginChainStateRepository.ORIGIN_HASH_INDEX_KEY) else {
                return
            }
            
            indexCache = XyoObjectStructure(value: XyoBuffer(data: encodedIndex))
            previousHashCache = XyoObjectStructure(value: XyoBuffer(data: encodedHash))
            statics = try getStoreStatics()
        } catch {
            // find way of handling this error
            return
        }
    }
    
    private func getStoreStatics () throws -> [XyoObjectStructure] {
        guard let encodedStatics = try store.read(key: XyoStorageOriginChainStateRepository.ORIGIN_STATTICS_KEY) else {
            return []
        }
        
        var returnArray: [XyoObjectStructure] = []
        let it = try XyoIterableStructure(value: XyoBuffer(data: encodedStatics)).getNewIterator()
        
        while try it.hasNext() {
            returnArray.append(try it.next())
        }
        
        return returnArray
    }
}
