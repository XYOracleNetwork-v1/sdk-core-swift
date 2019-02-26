//
//  XyoTcpPeerRepository.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 2/25/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public protocol XyoTcpPeerRepository {
    func getRandomPeer () -> XyoTcpPeer?
    func getPeers () -> [XyoTcpPeer]
    func addPeer (peer : XyoTcpPeer)
    func removePeer (peer : XyoTcpPeer)
}
