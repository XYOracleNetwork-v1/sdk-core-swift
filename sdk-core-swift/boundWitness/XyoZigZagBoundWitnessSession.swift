//
//  XyoZigZagBoundWitnessSession.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/24/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

class XyoZigZagBoundWitnessSession: XyoZigZagBoundWitness {
    private var cycles = 0
    private let pipe : XyoNetworkPipe
    private let choice : [UInt8]
    
    init(signers: [XyoSigner],
         signedPayload: [XyoObjectStructure],
         unsignedPayload: [XyoObjectStructure],
         pipe : XyoNetworkPipe,
         choice : [UInt8]) throws {
        
        self.pipe = pipe
        self.choice = choice
        
        try super.init(signers: signers, signedPayload: signedPayload, unsignedPayload: unsignedPayload)
    }
    
    public func doBoundWitness (transfer: XyoIterableStructure?) throws {
        if (!(try getIsCompleted())) {
            
        }
        
        
    }
    
    private func sendAndRecive (didHaveData: Bool, transfer: XyoIterableStructure?) throws -> XyoIterableStructure? {
        let returnData = try incomingData(transfer: transfer, endpoint: (cycles == 0 && didHaveData))
        
        if (cycles == 0 && !didHaveData) {
            let buffer = XyoBuffer()
            // todo make size include itself
            buffer.put(bits: UInt8(choice.count))
            buffer.put(bytes: choice)
            buffer.put(bytes: try returnData.getValueCopy().toByteArray())
            guard let response = 
        }
    }
    
}
