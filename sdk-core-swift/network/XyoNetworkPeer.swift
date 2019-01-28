//
//  XyoNetworkPeer.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/24/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public protocol XyoNetworkPeer {
    func getRole () -> [UInt8]
    func getPeerId () -> Int
}
