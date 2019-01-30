//
//  TcpTest.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/29/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public class XyoTcpSocket : NSObject, StreamDelegate {
    private var clientContect = CFStreamClientContext()
    private let writeStream : OutputStream
    private let readStream : InputStream
    
    init (writeStream : OutputStream!, readStream : InputStream!) {
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
        
        super.init()
        
        writeStream.schedule(in: .main, forMode: RunLoop.Mode.common)
        readStream.schedule(in: .main, forMode: RunLoop.Mode.common)
        
        writeStream.delegate = self
        readStream.delegate = self
        
        
    }
    
    let writeCallback:CFWriteStreamClientCallBack = {(stream:CFWriteStream?, eventType:CFStreamEventType, info:UnsafeMutableRawPointer?) in
    
    }
    
    let readCallback:CFReadStreamClientCallBack = {(stream:CFReadStream?, eventType:CFStreamEventType, info:UnsafeMutableRawPointer?) in
        
    }
    
    public func openWriteStream() {
        self.writeStream.open()
    }
    
    public func openReadStream () {
        self.readStream.open()
    }
    
    public func closeWriteStream() {
        self.writeStream.close()
    }
    
    public func closeReadStream() {
        self.readStream.close()
    }
    
    public func write (bytes : [UInt8], canBlock : Bool) -> Bool {
        let pointer = UnsafePointer<UInt8>(bytes)
        
        if (self.writeStream.hasSpaceAvailable || canBlock) {
             return self.writeStream.write(pointer, maxLength: bytes.count) == bytes.count
        }
        
        return false
    }
    
    public func read (size : Int, canBlock : Bool) -> [UInt8]? {
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        
        if(self.readStream.hasBytesAvailable || canBlock) {
            if (self.readStream.read(pointer, maxLength: size) == -1) {
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
        
        return XyoTcpSocket(writeStream: writeStream?.takeRetainedValue(), readStream: readStream!.takeRetainedValue())
        
    }
    
    private static let allCFFlags = CFOptionFlags(CFStreamEventType.openCompleted.rawValue |
        CFStreamEventType.hasBytesAvailable.rawValue |
        CFStreamEventType.endEncountered.rawValue |
        CFStreamEventType.errorOccurred.rawValue)
    
    private func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        print("YOO")
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            print("new message received")
            // readAvailableBytes(stream: aStream as! InputStream)
        case Stream.Event.endEncountered:
            closeReadStream()
            closeReadStream()
        case Stream.Event.errorOccurred:
            print("error occurred")
        case Stream.Event.hasSpaceAvailable:
            print("has space available")
        default:
            print("some other event...")
            break
        }
    }
}
