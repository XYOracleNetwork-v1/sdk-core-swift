//
//  XyoBridgeQueueRepository.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 2/25/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

public protocol XyoBridgeQueueRepository {
    func getQueue () -> [XyoBridgeQueueItem]
    func setQueue (queue : [XyoBridgeQueueItem])
    func addQueueItem (item : XyoBridgeQueueItem)
    func removeQueueItems (hashes : [XyoObjectStructure])
    func getLowestWeight (n : Int) -> [XyoBridgeQueueItem]
    func incrementWeights (hashes: [XyoObjectStructure])
    func commit ()
}
