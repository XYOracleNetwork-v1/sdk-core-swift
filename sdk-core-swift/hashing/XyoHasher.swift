//
//  XyoHasher.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/22/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

protocol XyoHasher {
    static func hash(data : [UInt8]) -> XyoObjectStructure
}
