//
//  XyoBridgeQueueItem.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public class XyoBridgeQueueItem {
    var weight : Int
    let hash : XyoObjectStructure
    
    init(weight: Int, hash: XyoObjectStructure) {
        self.weight = weight
        self.hash = hash
    }
}
