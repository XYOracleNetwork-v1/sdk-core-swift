//
//  XyoSha256.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/22/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import CommonCrypto
import sdk_objectmodel_swift

public struct XyoSha256 : XyoHasher {
    public init () {}
    
    public func hash(data: [UInt8]) -> XyoObjectStructure {
        var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        
        _ = digest.withUnsafeMutableBytes { (digestBytes) in
             CC_SHA256(data, CC_LONG(data.count), digestBytes)
        }
        
        let digestBytes = XyoBuffer(data: digest.map { $0 })
        
        return XyoObjectStructure.newInstance(schema: XyoSchemas.SHA_256, bytes: digestBytes)
    }
}
