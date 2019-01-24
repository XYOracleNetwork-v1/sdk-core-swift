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
}
