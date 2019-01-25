//
//  XyoBoundWitnessUtil.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/23/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

public struct XyoBoundWitnessUtil {
    
    public static func removeIdFromUnsignedPayload (id: UInt8, boundWitness : XyoIterableStructure) throws -> XyoIterableStructure {
        var newBoundWitnessLedger : [XyoObjectStructure] = []
        
        let fetters = try boundWitness.get(id: XyoSchemas.FETTER.id)
        let witnesses = try boundWitness.get(id: XyoSchemas.WITNESS.id)
        
        newBoundWitnessLedger.append(contentsOf: fetters)
        
        for witness in witnesses {
            var newWitnessContents : [XyoObjectStructure] = []
            
            guard let typedWitness = witness as? XyoIterableStructure else {
                throw XyoObjectError.NOT_ITERABLE
            }
            
            let it = try typedWitness.getNewIterator()
            
            while (try it.hasNext()) {
                let item = try it.next()
                
                if (try item.getSchema().id != id) {
                    newWitnessContents.append(item)
                }
            }
            
            newBoundWitnessLedger.append(try XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.WITNESS, values: newWitnessContents))
        }
        
        return try XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.BW, values: newBoundWitnessLedger)
    }
    
    public static func getPartyNumberFromPublicKey (publickey : XyoObjectStructure, boundWitness : XyoBoundWitness) throws -> Int? {
        for i in 0...(try boundWitness.getNumberOfParties() ?? 0) {
            
            guard let fetter = try boundWitness.getFetterOfParty(partyIndex: i) else {
                return nil
            }
            
            if (try checkPartyForPublicKey(fetter: fetter, publicKey: publickey)) {
                return i
            }
        }
        
        return nil
    }
    
    private static func checkPartyForPublicKey (fetter : XyoIterableStructure, publicKey : XyoObjectStructure) throws -> Bool {
        for keySet in (try fetter.get(id: XyoSchemas.KEY_SET.id)) {
            
            guard let typedKeyset = keySet as? XyoIterableStructure else {
                return false
            }
            
            let it = try typedKeyset.getNewIterator()
            
            while (try it.hasNext()) {
                if (try it.next().getBuffer().toByteArray() == publicKey.getBuffer().toByteArray()) {
                    return true
                }
            }
        }
        
        
        return false
    }
}