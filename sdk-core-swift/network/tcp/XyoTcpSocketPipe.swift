//
//  XyoTcpSocketPipe.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/29/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

public class XyoTcpSocketPipe: XyoNetworkPipe {
    private let socket : XyoTcpSocket
    private let initiationData : [UInt8]?
    
    
    public init(socket : XyoTcpSocket, initiationData: [UInt8]?) {
        self.socket = socket
        self.initiationData = initiationData
        
        self.socket.openReadStream()
        self.socket.openWriteStream()
    }
    
    public func getInitiationData() -> XyoAdvertisePacket? {
        if (initiationData == nil) {
            return nil
        }
        
        return XyoAdvertisePacket.init(data: initiationData.unsafelyUnwrapped)
    }
    
    public func send (data: [UInt8], waitForResponse: Bool) -> [UInt8]? {
        let dataWithSize = XyoBuffer()
            .put(bits: UInt32(data.count + 4))
            .put(bytes: data)
            .toByteArray()
        
        if (socket.write(bytes: dataWithSize, canBlock: true) == true) {
            if (waitForResponse) {
                guard let byteSize = socket.read(size: 4, canBlock: true) else {
                    return nil
                }
                
                let actualSize = XyoBuffer(data: byteSize).getUInt32(offset: 0) - 4
                return socket.read(size: Int(actualSize), canBlock: true)
            }
        }
        
        return nil
    }
    
    public func close () {
        self.socket.closeWriteStream()
        self.socket.closeWriteStream()
    }
}
