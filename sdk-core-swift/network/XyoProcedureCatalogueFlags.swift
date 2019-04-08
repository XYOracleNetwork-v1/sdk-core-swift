//
//  XyoProcedureCatalogue.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public struct XyoProcedureCatalogueFlags {
    public static let BOUND_WITNESS : UInt = 1
    public static let TAKE_ORIGIN_CHAIN : UInt = 2
    public static let GIVE_ORIGIN_CHAIN : UInt = 4
    
    public static func flip (flags: [UInt8]) -> [UInt8] {
        guard let intrestedInByte = flags.last else {
            return []
        }
        
        if (intrestedInByte & UInt8(XyoProcedureCatalogueFlags.TAKE_ORIGIN_CHAIN) != 0) {
            return [UInt8(XyoProcedureCatalogueFlags.GIVE_ORIGIN_CHAIN)]
        }
        
        if (intrestedInByte & UInt8(XyoProcedureCatalogueFlags.GIVE_ORIGIN_CHAIN) != 0) {
            return [UInt8(XyoProcedureCatalogueFlags.TAKE_ORIGIN_CHAIN)]
        }
        
         return [UInt8(XyoProcedureCatalogueFlags.BOUND_WITNESS)]
    }
}
