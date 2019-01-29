//
//  XyoHueresticPair.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

public struct XyoBoundWitnessHueresticPair {
    let unsignedPayload : [XyoObjectStructure]
    let signedPayload : [XyoObjectStructure]
    
    init (signedPayload: [XyoObjectStructure], unsignedPayload: [XyoObjectStructure]) {
        self.signedPayload = signedPayload
        self.unsignedPayload = unsignedPayload
    }
}
