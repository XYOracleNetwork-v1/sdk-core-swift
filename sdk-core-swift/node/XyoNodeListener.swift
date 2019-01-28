//
//  XyoNodeListener.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

open class XyoNodeListener {
    open func onBoundWitnessStart() {}
    open func onBoundWitnessDiscovered(boundWitness : XyoBoundWitness) {}
    open func onBoundWitnessEndFailure(error: XyoError) {}
    open func onBoundWitnessEndSuccess(boundWitness : XyoBoundWitness) {}
}
