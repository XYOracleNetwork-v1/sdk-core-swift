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
        let catalogue = XyoFlagProcedureCatalogue(forOther: 1 | 2 | 8,
                                                  withOther: 1 | 2 | 8)
        
        XCTAssertEqual(11, catalogue.getEncodedCatalogue())
    }
        
}

