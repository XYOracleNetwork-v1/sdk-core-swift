//
//  XyoBoundWitnessAppGroupManager.swift
//  Pods-Receiver
//
//  Created by Darren Sutherland on 6/6/19.
//

import Foundation

public class XyoBoundWitnessAppGroupManager: XyoAppGroupPipeListener {

    public typealias BoundWitnessHandler = (XyoNetworkHandler, XyoProcedureCatalogue, @escaping (XyoBoundWitness?, XyoError?) -> ()) -> Void

    private var asServer: Bool = false

    private var relayNode: XyoRelayNode?

    private var manager: XyoAppGroupPipeServer?

    private var onPipeHandler: BoundWitnessHandler?

    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    private class AppPipeCatalogue: XyoFlagProcedureCatalogue {
        private static let allSupportedFunctions = UInt32(XyoProcedureCatalogueFlags.BOUND_WITNESS)

        public init () {
            super.init(forOther: AppPipeCatalogue.allSupportedFunctions,
                       withOther: AppPipeCatalogue.allSupportedFunctions)
        }

        override public func choose(catalogue: [UInt8]) -> [UInt8] {
            guard let intrestedFlags = catalogue.last else {
                return []
            }

            if (intrestedFlags & UInt8(XyoProcedureCatalogueFlags.BOUND_WITNESS) != 0 && canDo(bytes: [UInt8(XyoProcedureCatalogueFlags.BOUND_WITNESS)])) {
                return [UInt8(XyoProcedureCatalogueFlags.BOUND_WITNESS)]
            }

            return []
        }
    }

    public init() {
        self.createNewRelayNode()
    }

    deinit {
        self.manager = nil
        self.onPipeHandler = nil
        self.endBackgroundTask()
    }

    private func endBackgroundTask() {
        // Cleanup of the task, otherwise iOS will kill the process
        UIApplication.shared.endBackgroundTask(self.backgroundTask)
        self.backgroundTask = .invalid
    }

    public func initiate(identifier: String) {
        // Allow this to be run in the background as you are switching to the server app
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }

        // Create the manager if not already existing
        if self.manager == nil {
            self.manager = XyoAppGroupPipeServer(listener: self)
        }

        // Start the transfer
        guard let pipe = self.manager?.requestConnection(identifier: String(identifier)) else { return }
        pipe.setFirstWrite { [weak self] in
            self?.relayNode?.boundWitness(handler: XyoNetworkHandler(pipe: pipe), procedureCatalogue: AppPipeCatalogue()) { _, _ in
                // TODO propogate this, throw or return in callback?
            }
        }
    }

    public func server(handler: @escaping BoundWitnessHandler) {
        self.onPipeHandler = handler
        self.asServer = true

        // Create the manager if not already existing
        if self.manager == nil {
            self.manager = XyoAppGroupPipeServer(listener: self, isServer: self.asServer)
        }
    }

    public func onPipe(pipe: XyoNetworkPipe) {
        guard self.asServer else { return }
        self.onPipeHandler?(XyoNetworkHandler(pipe: pipe), AppPipeCatalogue(), { _, _ in })
    }

    private func createNewRelayNode() {
        do {
            let storage = XyoInMemoryStorage()
            let blocks = XyoStrageProviderOriginBlockRepository(storageProvider: storage,hasher: XyoSha256())
            let state = XyoStorageOriginChainStateRepository(storage: storage)
            let conf = XyoRepositoryConfiguration(originState: state, originBlock: blocks)

            let node = XyoRelayNode(hasher: XyoSha256(),
                                    repositoryConfiguration: conf,
                                    queueRepository: XyoStorageBridgeQueueRepository(storage: storage))

            let signer = XyoSecp256k1Signer()
            node.originState.addSigner(signer: signer)

            try node.selfSignOriginChain()

            self.relayNode = node
        } catch {
            fatalError("Node should be able to sign its chain")
        }
    }

}
