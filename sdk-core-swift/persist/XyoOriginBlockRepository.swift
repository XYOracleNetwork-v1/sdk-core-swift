//
//  XyoOriginBlockRepository.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public protocol XyoOriginBlockRepository {
    func removeOriginBlock (originBlockHash : [UInt8]) throws
    func getOriginBlock (originBlockHash : [UInt8]) throws -> XyoBoundWitness?
    func containsOriginBlock (originBlockHash : [UInt8]) throws -> Bool
    func addOriginBlock (originBlock : XyoBoundWitness) throws
}
