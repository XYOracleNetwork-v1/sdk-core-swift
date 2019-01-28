//
//  XyoNetworkPipe.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/24/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import Promises

protocol XyoNetworkPipe {
    func getPeer() -> XyoNetworkPeer
    func getInitiationData() -> [UInt8]?
    func send (data: [UInt8], waitForResponse: Bool) -> [UInt8]?
    func close ()
}
