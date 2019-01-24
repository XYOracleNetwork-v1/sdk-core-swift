//
//  XyoBoundWitness.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/22/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

open class XyoBoundWitness : XyoIterableStructure {
    
    public func getIsCompleted () throws -> Bool {
        if (try self.get(id: XyoSchemas.WITNESS.id).count > 0) {
            return try self.get(id: XyoSchemas.FETTER.id).count == (try self.get(id: XyoSchemas.WITNESS.id).count)
        }
        
        return false
    }
    
    public func getNumberOfFetters () throws -> Int {
        return try self.get(id: XyoSchemas.FETTER.id).count
    }
    
    public func getNumberOfWitnesses () throws -> Int {
        return try self.get(id: XyoSchemas.WITNESS.id).count
    }
    
    public func getHash (hasher : XyoHasher) throws -> XyoObjectStructure {
        return try hasher.hash(data: getSigningData())
    }
    
    public func signCurrent(signer : XyoSigner) throws -> XyoObjectStructure {
        return try signer.sign(data: getSigningData())
    }
    
    internal func getSigningData () throws -> [UInt8] {
        return try getValueCopy().copyRangeOf(from: 0, to: getWitnessFetterBoundry()).toByteArray()
    }
    
    public func getNumberOfParties () throws -> Int? {
        let numberOfFetters = try self.get(id: XyoSchemas.FETTER.id).count
        let numberOfWitness = try self.get(id: XyoSchemas.WITNESS.id).count
        
        if (numberOfFetters == numberOfWitness) {
            return numberOfFetters
        }
        
        return nil
    }
    
    public func getFetterOfParty (partyIndex : Int) throws -> XyoIterableStructure? {
        guard let numberOfParties = try getNumberOfParties() else {
            return nil
        }
        
        if (numberOfParties <= partyIndex) {
            return nil
        }
        
        
        return try self.get(index: partyIndex) as? XyoIterableStructure
    }
    
    public func getWitnessOfParty (partyIndex : Int) throws -> XyoIterableStructure? {
        guard let numberOfParties = try getNumberOfParties() else {
            return nil
        }
        
        if (numberOfParties <= partyIndex) {
            return nil
        }
        
        
        return try self.get(index: (numberOfParties * 2) - (partyIndex + 1)) as? XyoIterableStructure
    }
    
    private func getWitnessFetterBoundry () throws -> Int {
        let fetters = try self.get(id: XyoSchemas.FETTER.id)
        var offsetIndex = 0
        
        for fetter in fetters {
            offsetIndex += try fetter.getSize() + 2
        }
        
        return offsetIndex
    }
    
    static func createFetter (payload: [XyoObjectStructure], publicKeys: [XyoObjectStructure]) throws -> XyoObjectStructure {
        let keyset = try XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.KEY_SET, values: publicKeys)
        var itemsInFetter = payload
        itemsInFetter.append(keyset)
        return try XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.FETTER, values: itemsInFetter)
    }
    
    static func createWitness (unsignedPayload: [XyoObjectStructure], publicKeys: [XyoObjectStructure]) throws -> XyoObjectStructure {
        let keyset = try XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.SIGNATURE_SET, values: publicKeys)
        var itemsInWitness = unsignedPayload
        itemsInWitness.append(keyset)
        return try XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.WITNESS, values: itemsInWitness)
    }
}
