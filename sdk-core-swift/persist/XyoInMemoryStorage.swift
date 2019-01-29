//
//  XyoInMemoryStorage.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

class XyoInMemoryStorage: XyoStorageProvider {
    private var storageMap = [[UInt8] : [UInt8]]()
    
    func write (key : [UInt8], value: [UInt8]) throws {
        storageMap[key] = value
    }
    
    func read (key : [UInt8]) throws -> [UInt8]? {
        return storageMap[key]
    }
    
    func delete (key : [UInt8]) throws {
        storageMap.removeValue(forKey: key)
    }
    
    func containsKey (key : [UInt8]) throws -> Bool {
        return storageMap.contains {
            $0.key == key
        }
    }
}
