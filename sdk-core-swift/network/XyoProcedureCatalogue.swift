//
//  XyoProcedureCatalogue.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public protocol XyoProcedureCatalogue {
    func canDo (bytes : [UInt8]) -> Bool
    func getEncodedCatalogue() -> [UInt8]
}