//
//  XyoBridgeTakeCatalogue.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 4/8/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_core_swift

class TestTakeOriginChainCatalogue : XyoFlagProcedureCatalogue {
    
    public init () {
        super.init(forOther: UInt32(XyoProcedureCatalogueFlags.GIVE_ORIGIN_CHAIN),
                   withOther: UInt32(XyoProcedureCatalogueFlags.TAKE_ORIGIN_CHAIN))
    }
    
    override public func choose(catalogue: [UInt8]) -> [UInt8] {
        guard let intrestedFlags = catalogue.last else {
            fatalError()
        }
        
        if (intrestedFlags & UInt8(XyoProcedureCatalogueFlags.TAKE_ORIGIN_CHAIN) != 0 && canDo(bytes: [UInt8(XyoProcedureCatalogueFlags.TAKE_ORIGIN_CHAIN)])) {
            return [UInt8(XyoProcedureCatalogueFlags.GIVE_ORIGIN_CHAIN)]
        }
        
        fatalError()
    }
}
