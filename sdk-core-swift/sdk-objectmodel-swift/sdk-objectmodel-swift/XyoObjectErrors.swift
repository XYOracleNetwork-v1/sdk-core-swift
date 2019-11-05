//
//  XyoObjectErrors.swift
//  sdk-objectmodel-swift
//
//  Created by Carter Harrison on 1/21/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public enum XyoObjectError: Error {
    case SIZE_ZERO
    case NOT_ITERABLE
    case OUT_OF_INDEX
    case NOT_UNTYPED
    case NOT_TYPED
    case NO_ELEMENTS
    case WRONG_TYPE
}
