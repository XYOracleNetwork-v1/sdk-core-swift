//
//  XyoNetworkHandler.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/29/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

public class XyoNetworkHandler {
    let pipe : XyoNetworkPipe
    
    public init(pipe: XyoNetworkPipe) {
        self.pipe = pipe
    }
    
    func sendCataloguePacket (catalogue : [UInt8]) -> XyoChoicePacket? {
        let buffer = getSizeEncodedCatalogue(catalogue: catalogue)
        
        guard let response = pipe.send(data: buffer, waitForResponse: true) else {
            return nil
        }
        
        return XyoChoicePacket(data: response)
    }
    
    func sendChoicePacket (catalogue : [UInt8], reponse : [UInt8]) -> [UInt8]? {
        let buffer = XyoBuffer()
            .put(bytes: getSizeEncodedCatalogue(catalogue: catalogue))
            .put(bytes: reponse)
            .toByteArray()
        
        return pipe.send(data: buffer, waitForResponse: true)
    }
    
    private func getSizeEncodedCatalogue (catalogue : [UInt8]) -> [UInt8] {
        return XyoBuffer()
            .put(bits: UInt8(catalogue.count))
            .put(bytes: catalogue)
            .toByteArray()
    }
}
