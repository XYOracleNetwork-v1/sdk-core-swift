//
//  XyoStrageProviderOriginBlockRepository.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

public class XyoStrageProviderOriginBlockRepository: XyoOriginBlockRepository {
    private let storageProvider : XyoStorageProvider
    private let hasher : XyoHasher
    
    public init(storageProvider : XyoStorageProvider, hasher : XyoHasher) throws {
        self.storageProvider = storageProvider
        self.hasher = hasher
    }
    
    public func removeOriginBlock (originBlockHash : [UInt8]) throws {
        try storageProvider.delete(key: originBlockHash)
    }
    
    public func getOriginBlock (originBlockHash : [UInt8]) throws -> XyoBoundWitness? {
        guard let packedBlock = try storageProvider.read(key: originBlockHash) else {
            return nil
        }
        
        return XyoBoundWitness(value: XyoBuffer(data: packedBlock))
    }
    
    public func containsOriginBlock (originBlockHash : [UInt8]) throws -> Bool {
        return try storageProvider.containsKey(key: originBlockHash)
    }
    
    public func addOriginBlock (originBlock : XyoBoundWitness) throws {
        let key = try originBlock.getHash(hasher: hasher).getBuffer().toByteArray()
        let value = originBlock.getBuffer().toByteArray()
        
        try storageProvider.write(key: key, value: value)
    }
}
