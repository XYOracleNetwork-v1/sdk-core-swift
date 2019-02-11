//
//  XyoFlagProcedureCatalogue.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

public class XyoFlagProcedureCatalogue : XyoProcedureCatalogue {
    private let encodedCatalogue : [UInt8]
    public let canDoForOther : UInt32
    public let canDoWithOther : UInt32
    
    public init(forOther : UInt32, withOther : UInt32) {
        self.canDoForOther = forOther
        self.canDoWithOther = withOther
        self.encodedCatalogue = XyoBuffer()
            .put(bits: canDoForOther)
            .toByteArray()
    }
    
    public func canDo (bytes : [UInt8]) -> Bool {
        for i in 0...(min(bytes.count, encodedCatalogue.count) - 1) {
            let otherCatalogueSection = bytes[bytes.count - i - 1]
            let thisCatalogueSection = encodedCatalogue[encodedCatalogue.count - i - 1]
            
            if (otherCatalogueSection & thisCatalogueSection != 0) {
                return true
            }
        }
        
        return false
    }
    
    public func getEncodedCatalogue() -> [UInt8] {
        return encodedCatalogue
    }
    
    open func choose(catalogue: [UInt8]) -> [UInt8] {
        // return [UInt8(XyoProcedureCatalogueFlags.GIVE_ORIGIN_CHAIN)]
        return [UInt8(XyoProcedureCatalogueFlags.BOUND_WITNESS)]
    }
}
