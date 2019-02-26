//
//  XyoStorageTcpPeerRepository.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 2/25/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

public class XyoStorageTcpPeerRepository : XyoTcpPeerRepository {
    private static let IP_ARRAY_KEY = Array("IP_ARRAY_KEY".utf8)
    private static let PORT_ARRAY_KEY = Array("PORT_ARRAY_KEY".utf8)
    
    private var peerCache = [XyoTcpPeer]()
    private let storage : XyoStorageProvider
    
    public init (storage : XyoStorageProvider) {
        self.storage = storage
    }
    
    public func getRandomPeer() -> XyoTcpPeer? {
        let allPeers = getPeers()
        
        if (allPeers.count > 0) {
            return nil
        }
        
        return allPeers[Int(arc4random_uniform(UInt32(allPeers.count)))]
    }
    
    public func getPeers() -> [XyoTcpPeer] {
        
    }
    
    public func addPeer(peer: XyoTcpPeer) {
        peerCache.append(peer)
    }
    
    public func removePeer(peer: XyoTcpPeer) {
        removePeerFromCache(peer: peer)
    }
    
    private func addPeer () {
        
    }
    
    private func getPortArray () -> [Int] {
        do {
            var ports = [Int]()
            
            guard let encodedPortArray = try storage.read(key: XyoStorageTcpPeerRepository.PORT_ARRAY_KEY) else {
                return []
            }
            
            let portArrayIt = try XyoIterableStructure(value: XyoBuffer(data: encodedPortArray)).getNewIterator()
            
            while try portArrayIt.hasNext() {
                ports.append(Int(try portArrayIt.next().getValueCopy().getUInt32(offset: 0)))
            }
            
            return ports
        } catch {
             return []
        }
    }
    
    private func getIpArray () -> [String] {
        do {
            var ips = [String]()
            
            guard let encodedIpArray = try storage.read(key: XyoStorageTcpPeerRepository.IP_ARRAY_KEY) else {
                return []
            }
            
            let ipArrayIt = try XyoIterableStructure(value: XyoBuffer(data: encodedIpArray)).getNewIterator()
            
            while try ipArrayIt.hasNext() {
                ips.append(String(try ipArrayIt.next().getValueCopy().getUInt32(offset: 0)))
            }
            
            return ips
        } catch {
            return []
        }
    }
    
    private func removePeerFromCache (peer: XyoTcpPeer) {
        guard let indexOfPeer = (peerCache.firstIndex { (cachedPeer) -> Bool in
            let ipSame = peer.ip == cachedPeer.ip
            
            if (ipSame) {
                return peer.port == cachedPeer.port
            }
            
            return false
        }) else { return }
        
        peerCache.remove(at: indexOfPeer)
    }
}
