//
//  XyoFlagPrecedureCatalogueTest.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
import sdk_objectmodel_swift
@testable import sdk_core_swift

class XyoFlagPrecedureCatalogueTest: XCTestCase {
    
    func testGetEncodedCatalogue () {
        let catalogue = XyoFlagProcedureCatalogue(forOther: 1,
                                                  withOther: 1)
        
        XCTAssertEqual([0x00, 0x00, 0x00, 0x01], catalogue.getEncodedCatalogue())
    }
    
    func testCanDoFalseCaseOne () {
        let catalogue = XyoFlagProcedureCatalogue(forOther: 1,
                                                  withOther: 1)
        
        XCTAssertEqual(false, catalogue.canDo(bytes: [0x01, 0x00]))
    }
    
    func testCanDoFalseCaseTwo () {
        let catalogue = XyoFlagProcedureCatalogue(forOther: 4,
                                                  withOther: 4)
        
        XCTAssertEqual(false, catalogue.canDo(bytes: [0xff, 0x00, 0x01, 0x00]))
    }
    
    func testCanDoFalseCaseThree () {
        let catalogue = XyoFlagProcedureCatalogue(forOther: 8,
                                                  withOther: 8)
                
        XCTAssertEqual(false, catalogue.canDo(bytes: [0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x01, 0x00]))
    }
    
    func testCanDoTrueCaseOne () {
        let catalogue = XyoFlagProcedureCatalogue(forOther: 8,
                                                  withOther: 8)
        
        XCTAssertEqual(true, catalogue.canDo(bytes: [0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x01, 0xff]))
    }
    
    func testCanDoTrueCaseTwo () {
        let catalogue = XyoFlagProcedureCatalogue(forOther: 8,
                                                  withOther: 8)
        
        XCTAssertEqual(true, catalogue.canDo(bytes: [0x08]))
    }
    
    func testCanDoTrueCaseThree () {
        let catalogue = XyoFlagProcedureCatalogue(forOther: 1,
                                                  withOther: 1)
        
        XCTAssertEqual(true, catalogue.canDo(bytes: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]))
    }
        
}

