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
    public let canDoForOther : UInt32
    public let canDoWithOther : UInt32
    
    init(forOther : UInt32, withOther : UInt32) {
        self.canDoForOther = forOther
        self.canDoWithOther = withOther
    }
    
    public func canDo (bytes : [UInt8]) -> Bool {
        for i in 0...bytes.count - 1 {
            let bitShift = (bytes.count - i) * 8
            
            if (bitShift <= 32) {
                if (bytes[i] & UInt8((canDoWithOther << bitShift) & 0xFF)  != 0) {
                    return true
                }
            }
        }
        
        return false
    }
    
    public func getEncodedCatalogue() -> [UInt8] {
        return XyoBuffer()
            .put(bits: canDoForOther)
            .toByteArray()
    }
}
