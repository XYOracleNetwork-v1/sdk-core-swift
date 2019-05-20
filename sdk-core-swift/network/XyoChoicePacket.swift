//
//  XyoChoicePacket.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/29/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

public struct XyoChoicePacket {
    private let data : [UInt8]

    init(data : [UInt8]) {
        self.data = data
    }
    
    func getChoice () throws -> [UInt8] {
        if (data.count == 0) {
            throw XyoObjectError.OUT_OF_INDEX
        }
        
        let sizeOfChoice = getSizeOfChoice()
        
        if (sizeOfChoice + 1 > data.count || sizeOfChoice == 0) {
            throw XyoObjectError.OUT_OF_INDEX
        }
        
        return XyoBuffer(data: data).copyRangeOf(from: 1, to: sizeOfChoice + 1).toByteArray()
    }
    
    func getResponce () throws -> [UInt8] {
        if (data.count == 0) {
            throw XyoObjectError.OUT_OF_INDEX
        }
        
        let sizeOfChoice = getSizeOfChoice()
        
        if (sizeOfChoice + 1 > data.count || sizeOfChoice == 0) {
            throw XyoObjectError.OUT_OF_INDEX
        }
        
        return XyoBuffer(data: data).copyRangeOf(from: sizeOfChoice + 1, to: data.count).toByteArray()
    }
    
    private func getSizeOfChoice () -> Int {
        return Int(XyoBuffer(data: data).getUInt8(offset: 0))
    }
}
