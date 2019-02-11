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
    private let handler : XyoNetworkHandler
    private let choice : [UInt8]
    
    init(signers: [XyoSigner],
         signedPayload: [XyoObjectStructure],
         unsignedPayload: [XyoObjectStructure],
         handler : XyoNetworkHandler,
         choice : [UInt8]) throws {
        
        self.handler = handler
        self.choice = choice
        
        try super.init(signers: signers, signedPayload: signedPayload, unsignedPayload: unsignedPayload)
    }
    
    public func doBoundWitness (transfer: XyoIterableStructure?) throws {
        if (try !getIsCompleted()) {
            let response = try sendAndRecive(didHaveData: transfer != nil, transfer: transfer)
            
            if (cycles == 0 && transfer != nil && response != nil) {
                _ = try incomingData(transfer: response, endpoint: false)
                return
            }
            
            cycles += 1
            return try doBoundWitness(transfer: response)
            
        }
    }
    
    private func sendAndRecive (didHaveData: Bool, transfer: XyoIterableStructure?) throws -> XyoIterableStructure? {
        let returnData = try incomingData(transfer: transfer, endpoint: (cycles == 0 && didHaveData))
        
        if (cycles == 0 && !didHaveData) {
            return try sendAndReciveWithChoice(returnData : returnData, transfer: transfer)
        }
        
        guard let response = handler.pipe.send(data: returnData.getBuffer().toByteArray(), waitForResponse: cycles == 0) else {
            if (cycles == 0) {
                throw XyoError.RESPONSE_IS_NULL
            }
            
            return nil
        }
        
        return XyoIterableStructure(value: XyoBuffer(data: response))
    
    }
    
    private func sendAndReciveWithChoice (returnData: XyoIterableStructure, transfer: XyoIterableStructure?) throws -> XyoIterableStructure? {
        guard let response =  handler.sendChoicePacket(catalogue: choice, reponse: returnData.getBuffer().toByteArray()) else {
            throw XyoError.RESPONSE_IS_NULL
        }
        
        return XyoIterableStructure(value: XyoBuffer(data: response))
    }
}
