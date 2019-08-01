//
//  XyoSchemas.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/22/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

public struct XyoSchemas {
    // offical schemas
    public static let ARRAY_TYPED =             XyoObjectSchema(id: 01, encodingCatalog: 0xb0)
    public static let ARRAY_UNTYPED =           XyoObjectSchema(id: 01, encodingCatalog: 0xa0)
    public static let BW =                      XyoObjectSchema(id: 02, encodingCatalog: 0xa0)
    public static let INDEX =                   XyoObjectSchema(id: 03, encodingCatalog: 0x80)
    public static let NEXT_PUBLIC_KEY =         XyoObjectSchema(id: 04, encodingCatalog: 0x80)
    public static let BRIDGE_BLOCK_SET =        XyoObjectSchema(id: 05, encodingCatalog: 0xa0)
    public static let BRIDGE_HASH_SET =         XyoObjectSchema(id: 06, encodingCatalog: 0xb0)
    public static let PAYMENT_KEY =             XyoObjectSchema(id: 07, encodingCatalog: 0x80)
    public static let PREVIOUS_HASH =           XyoObjectSchema(id: 08, encodingCatalog: 0xb0)
    public static let EC_SIGNATURE =            XyoObjectSchema(id: 09, encodingCatalog: 0x80)
    public static let RSA_SIGNATURE =           XyoObjectSchema(id: 10, encodingCatalog: 0x80)
    public static let STUB_SIGNATURE =          XyoObjectSchema(id: 11, encodingCatalog: 0x80)
    public static let EC_PUBLIC_KEY =           XyoObjectSchema(id: 12, encodingCatalog: 0x80)
    
    public static let RSA_PUBLIC_KEY =          XyoObjectSchema(id: 13, encodingCatalog: 0x80)
    public static let STUB_PUBLIC_KEY =         XyoObjectSchema(id: 14, encodingCatalog: 0x80)
    public static let STUB_HASH =               XyoObjectSchema(id: 15, encodingCatalog: 0x80)
    public static let SHA_256 =                 XyoObjectSchema(id: 16, encodingCatalog: 0x80)
    public static let SHA_3 =                   XyoObjectSchema(id: 17, encodingCatalog: 0x80)
    public static let GPS =                     XyoObjectSchema(id: 18, encodingCatalog: 0xa0)
    public static let RSSI =                    XyoObjectSchema(id: 19, encodingCatalog: 0x80)
    public static let UNIX_TIME =               XyoObjectSchema(id: 20, encodingCatalog: 0x80)
    
    public static let FETTER =                  XyoObjectSchema(id: 21, encodingCatalog: 0xa0)
    public static let FETTER_SET =              XyoObjectSchema(id: 22, encodingCatalog: 0xb0)
    public static let WITNESS =                 XyoObjectSchema(id: 23, encodingCatalog: 0xa0)
    public static let WITNESS_SET =             XyoObjectSchema(id: 24, encodingCatalog: 0xb0)
    public static let KEY_SET =                 XyoObjectSchema(id: 25, encodingCatalog: 0xa0)
    public static let SIGNATURE_SET =           XyoObjectSchema(id: 26, encodingCatalog: 0xa0)
    public static let BW_FRAGMENT =             XyoObjectSchema(id: 27, encodingCatalog: 0xa0)
    public static let LAT =                     XyoObjectSchema(id: 28, encodingCatalog: 0x80)
    public static let LNG =                     XyoObjectSchema(id: 29, encodingCatalog: 0x80)
    public static let BLE_POWER_LEVEL =         XyoObjectSchema(id: 30, encodingCatalog: 0x80)
    
    // custum
    public static let STUB_PRIVATE_KEY =        XyoObjectSchema(id: 0xff, encodingCatalog: 0x80)
    public static let EC_PRIVATE_KEY =          XyoObjectSchema(id: 0xff, encodingCatalog: 0x80)
    public static let RSA_PRIVATE_KEY =         XyoObjectSchema(id: 0xff, encodingCatalog: 0x80)
    public static let BLOB =                    XyoObjectSchema(id: 0xff, encodingCatalog: 0x80)
    
}
