//
//  XyoBoundWitnessUtilTest.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 1/23/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

import XCTest
import sdk_objectmodel_swift
@testable import sdk_core_swift

class XyoBoundWitnessUtilTest: XCTestCase {
    
    func testRemoveIdFromBoundWitness() throws {
        let rawBoundWitness = "600201A22015CB2019C8000C41170F9302323929FD3FD8A72851F73866A0BFC6D488040E9D921689E01B9E25E4393B0984576763DD9C5DA95E609A80B4CC12064758C1AEEE28AE264015BF474F000D8200AEB335766EC511499DDE566579B4ED1562079AA543388B2EDED68ED68363AE9DAE25E7E29B9A5607E676A5F50CC6EB5CBCEBDEE30FB3F1CB9DA0074D4D3CA29B8BFD42AEEE44CA7C26134F4401FF67332C549AD72B36FBF9211D07B0B825C137D6A0DD13EE35FE446B55D22E66CE751216DC4BB823A3A62C3D0208CAC0DF68AB2017D1201ACA00094421009A0FF234B98891EE3FF99365A3CA6AB804173F1A8619934134A68F59FBDCA92E200C04A196D4A39C987C984E18B79D3EE81667DD92E962E6C630DB5D7BDCDB1988000A81713AB83E5D8B4EF6D2EAB4D70B61AADCA01E733CB0B3D072DE307CDBCD09F46D528A7159EB73DEBB018871E30D182F5BBB426689E758A7BFD4C51D0AD116CA621BF1C39DA49A837D525905D22BAB7C1874F6C7E6B4D56139A15C3BE1D1DC8E061C241C060A24B588217E37D6206AFE5D71F4698D42E25C4FCE996EECCF7690B900130200".hexStringToBytes()
        let boundWitness = XyoBoundWitness(value: XyoBuffer(data: rawBoundWitness))
        
        try drilDown(item: boundWitness)
        
//        let witnesses = try boundWitness.get(id: XyoSchemas.WITNESS.id)
        
//        for witness in witnesses {
//
//            guard let typedWitness = witness as? XyoIterableStructure else {
//                throw XyoObjectError.NOT_ITERABLE
//            }
//
//            print(typedWitness.getBuffer().toByteArray().toHexString())
//
//            let it = try typedWitness.getNewIterator()
//
//            while (it.hasNext()) {
//                print(try it.next().getSchema().id)
//                if (try it.next().getSchema().id == XyoSchemas.RSSI.id) {
//                    throw XyoError.EXTREME_TESTING_ERROR
//                }
//            }
//        }
    }
    
    func drilDown (item : XyoIterableStructure) throws {
        let it = try item.getNewIterator()
        
        while try it.hasNext() {
            let value = try it.next()
            
            if (value is XyoIterableStructure) {
                try drilDown(item: (value as! XyoIterableStructure))
            }
        }
    }
}
