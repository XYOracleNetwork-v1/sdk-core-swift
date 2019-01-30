//
//  XyoOriginBoundWitnessUtil.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

struct XyoOriginBoundWitnessUtil {
    
    public static func getBridgeBlocks (boundWitness : XyoBoundWitness) throws -> XyoIterableStructure? {
        let witnesses = try boundWitness.get(id: XyoSchemas.WITNESS.id)
        
        for witness in witnesses {
            guard let typedWitness = witness as? XyoIterableStructure else {
                throw XyoError.MUST_BE_FETTER_OR_WITNESS
            }
            
            let blockset = try typedWitness.get(id: XyoSchemas.BRIDGE_BLOCK_SET.id)

            for item in blockset {
                return item as? XyoIterableStructure
            }
        }
        
        return nil
    }
    
}
