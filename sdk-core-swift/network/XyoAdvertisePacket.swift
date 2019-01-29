//
//  XyoAdvertisePacket.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/29/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

public struct XyoAdvertisePacket {
    private let data : [UInt8]
    
    func getChoice () -> [UInt8] {
        let sizeOfChoice = Int(XyoBuffer(data: data).getUInt8(offset: 0))
        return XyoBuffer(data: data).copyRangeOf(from: 1, to: sizeOfChoice + 1).toByteArray()
    }

    init(data : [UInt8]) {
        self.data = data
    }
}
