//
//  XyoStorageBridgeQueueRepository.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 2/26/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

class XyoStorageBridgeQueueRepository: XyoBridgeQueueRepository {
    private static let QUEUE_ARRAY_INDEX_KEY = Array("QUEUE_ARRAY_INDEX_KEY".utf8)
    
    private let store : XyoStorageProvider
    private var queueCache = [XyoBridgeQueueItem]()
    
    init(storage : XyoStorageProvider) {
        self.store = storage
    }
    
    func getQueue() -> [XyoBridgeQueueItem] {
        return queueCache
    }
    
    func setQueue(queue: [XyoBridgeQueueItem]) {
        queueCache = queue
        saveQueue(items: queueCache)
    }
    
    func addQueueItem(item: XyoBridgeQueueItem) {
        queueCache.append(item)
        saveQueue(items: queueCache)
    }
    
    func removeQueueItem(hash: XyoObjectStructure) {
        removeItemFromQueueCache(hash: hash)
        saveQueue(items: queueCache)
    }
    
    func restoreQueue () {
        var items = [XyoBridgeQueueItem]()
        
        do {
            guard let encodedIndex = try store.read(key: XyoStorageBridgeQueueRepository.QUEUE_ARRAY_INDEX_KEY) else {
                return
            }
            
            let iterableIndex = try XyoIterableStructure(value: XyoBuffer(data: encodedIndex)).getNewIterator()
            
            while try iterableIndex.hasNext() {
                let structure = try iterableIndex.next() as? XyoIterableStructure
                
                if (structure != nil) {
                    let created = XyoBridgeQueueItem.fromStructure(structure: structure!)
                    
                    if (created != nil) {
                        items.append(created!)
                    }
                }
                
            }
        } catch {
            // handle this error
        }
    }
    
    private func saveQueue (items : [XyoBridgeQueueItem]) {
        var structures = [XyoObjectStructure]()
        
        for item in items {
            structures.append(item.toStructre())
        }
        
        do {
            let encodedIndex = try XyoIterableStructure.createTypedIterableObject(schema: XyoSchemas.ARRAY_TYPED, values: structures).getBuffer().toByteArray()
            try store.write(key: XyoStorageBridgeQueueRepository.QUEUE_ARRAY_INDEX_KEY, value: encodedIndex)
        } catch {
            // todo handle this error
        }
    }
    
    private func removeItemFromQueueCache (hash: XyoObjectStructure) {
        guard let indexOfItem = (queueCache.firstIndex { (cachedItem) -> Bool in
            return cachedItem.hash.getBuffer().toByteArray() == hash.getBuffer().toByteArray()
        }) else { return }
        
        queueCache.remove(at: indexOfItem)
    }
}

extension XyoBridgeQueueItem {
    func toStructre () -> XyoObjectStructure {
        let weightStructure = XyoObjectStructure.newInstance(schema: XyoSchemas.BLOB, bytes: XyoBuffer().put(bits: UInt32(self.weight)))
        let hashStructre = self.hash
        
        return XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.ARRAY_UNTYPED, values: [hashStructre, weightStructure])
    }
    
    static func fromStructure (structure : XyoIterableStructure) -> XyoBridgeQueueItem? {
        do {
            let weight = try structure.get(index: 0).getValueCopy().getUInt32(offset: 0)
            let hash = try structure.get(index: 1)
            
            return XyoBridgeQueueItem(weight: Int(weight), hash: hash)
        } catch {
            return nil
        }
    }
}
