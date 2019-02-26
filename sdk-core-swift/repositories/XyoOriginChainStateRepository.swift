//
//  XyoOriginChainStateRepository.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 2/25/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

public protocol XyoOriginChainStateRepository {
    func getIndex () -> XyoObjectStructure?
    func putIndex (index : XyoObjectStructure)
    func getPreviousHash () -> XyoObjectStructure?
    func putPreviousHash (hash : XyoObjectStructure)
    func getSigners () -> [XyoSigner]
    func removeOldestSigner ()
    func putSigner (signer : XyoSigner)
}
