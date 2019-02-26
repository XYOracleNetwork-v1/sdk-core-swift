//
//  XyoStorageOriginChainStateRepository.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 2/26/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

class XyoStorageOriginChainStateRepository: XyoOriginChainStateRepository {
    private var signersCache = [XyoSigner]()
    private var indexCache : XyoObjectStructure? = nil
    private var previousHashCache : XyoObjectStructure? = nil
    
    private let store : XyoStorageProvider
    private static let ORIGIN_STATE_INDEX_KEY = Array("QUEUE_ARRAY_INDEX_KEY".utf8)
    private static let ORIGIN_HASH_INDEX_KEY = Array("ORIGIN_HASH_INDEX_KEY".utf8)
    
    init(storage : XyoStorageProvider) {
        self.store = storage
    }
    
    func getIndex() -> XyoObjectStructure? {
        return indexCache
    }
    
    func putIndex(index: XyoObjectStructure) {
        indexCache = index
    }
    
    func getPreviousHash() -> XyoObjectStructure? {
        return previousHashCache
    }
    
    func putPreviousHash(hash: XyoObjectStructure) {
        previousHashCache = hash
    }
    
    func getSigners() -> [XyoSigner] {
        return signersCache
    }
    
    func removeOldestSigner() {
        if (signersCache.count > 0) {
            signersCache.removeFirst()
        }
    }
    
    func putSigner(signer: XyoSigner) {
        signersCache.append(signer)
    }
    
    func restoreState (signers : [XyoSigner]) {
        do {
            guard let encodedIndex = try store.read(key: XyoStorageOriginChainStateRepository.ORIGIN_STATE_INDEX_KEY) else {
                return
            }
            
            guard let encodedHash = try store.read(key: XyoStorageOriginChainStateRepository.ORIGIN_HASH_INDEX_KEY) else {
                return
            }
            
            indexCache = XyoObjectStructure(value: XyoBuffer(data: encodedIndex))
            previousHashCache = XyoObjectStructure(value: XyoBuffer(data: encodedHash))
            signersCache = signers
        } catch {
            // find way of handling this error
            return
        }
    }
}
