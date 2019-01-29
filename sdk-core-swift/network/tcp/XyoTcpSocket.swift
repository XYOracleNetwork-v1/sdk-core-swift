//
//  TcpTest.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/29/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public class XyoTcpSocket {
    private var clientContect = CFStreamClientContext()
    private let writeStream : CFWriteStream
    private let readStream : CFReadStream
    
    init (writeStream : CFWriteStream, readStream : CFReadStream) {
        self.readStream = readStream
        self.writeStream = writeStream
        
        CFWriteStreamSetClient(writeStream,
                               XyoTcpSocket.allCFFlags,
                               writeCallback,
                               &clientContect)
        
        CFReadStreamSetClient(readStream,
                              XyoTcpSocket.allCFFlags,
                              readCallback,
                              &clientContect)
    }
    
    let writeCallback:CFWriteStreamClientCallBack = {(stream:CFWriteStream?, eventType:CFStreamEventType, info:UnsafeMutableRawPointer?) in
    
    }
    
    let readCallback:CFReadStreamClientCallBack = {(stream:CFReadStream?, eventType:CFStreamEventType, info:UnsafeMutableRawPointer?) in
        
    }
    
    public func openWriteStream() {
        CFWriteStreamOpen(self.writeStream)
    }
    
    public func openReadStream () {
        CFReadStreamOpen(self.readStream)
    }
    
    public func closeWriteStream() {
        CFWriteStreamClose(self.writeStream)
    }
    
    public func closeReadStream() {
        CFReadStreamClose(self.readStream)
    }
    
    public func write (bytes : [UInt8]) -> Bool {
        let pointer = UnsafePointer<UInt8>(bytes)
        let index : CFIndex = CFIndex(bytes.count)
        
        if (CFWriteStreamCanAcceptBytes(self.writeStream)) {
             return CFWriteStreamWrite(self.writeStream, pointer, index) == bytes.count
        }
        
        return false
    }
    
    public func read (size : Int, canBlock : Bool) -> [UInt8]? {
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        let index : CFIndex = CFIndex(size)
        
        
        if(CFReadStreamOpen(self.readStream) || canBlock) {
            if (CFReadStreamRead(self.readStream, pointer, index) == -1) {
                return nil
            }
            
             return Array(UnsafeMutableBufferPointer(start: pointer, count: size))
        }
    
        return nil
    }
    
    
    static func create(ip : String, port: Int) -> XyoTcpSocket {
        var readStream : Unmanaged<CFReadStream>?
        var writeStream : Unmanaged<CFWriteStream>?
        let host : CFString = NSString(string: ip)
        let port : UInt32 = UInt32(port)
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host, port, &readStream, &writeStream)
        
        return XyoTcpSocket(writeStream: writeStream!.takeUnretainedValue(), readStream: readStream!.takeUnretainedValue())
        
    }
    
    private static let allCFFlags = CFOptionFlags(CFStreamEventType.openCompleted.rawValue |
        CFStreamEventType.hasBytesAvailable.rawValue |
        CFStreamEventType.endEncountered.rawValue |
        CFStreamEventType.errorOccurred.rawValue)
    
}
