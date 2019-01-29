//
//  XyoNodeListener.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public protocol XyoNodeListener {
    func onBoundWitnessStart()
    func onBoundWitnessDiscovered(boundWitness : XyoBoundWitness)
    func onBoundWitnessEndFailure()
    func onBoundWitnessEndSuccess(boundWitness : XyoBoundWitness)
}
