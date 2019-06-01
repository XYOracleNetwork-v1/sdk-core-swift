//
//  XyoAppGroupManager.swift
//  sdk-core-swift
//
//  Created by Darren Sutherland on 5/31/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public protocol XyoAppGroupPipeListener {
    func onPipe (pipe: XyoNetworkPipe)
}

public protocol XyoAppGroupManagerListener: class {
    func onClose (bundleIdentifier : String)
}

/// Allows for a client to request a pipe be created to connect to a server
public class XyoAppGroupPipeManager {

    fileprivate lazy var pipes = [String: XyoAppGroupPipe]()

    fileprivate struct Constants {
        static let filename = "appgrouprequest"
        static let fileExtension = "xyonetwork"
    }

    fileprivate let listener: XyoAppGroupPipeListener

    fileprivate let fileManager: XyoSharedFileManager?

    public init(listener: XyoAppGroupPipeListener, bundleIdentifier: String, groupIdentifier: String = XyoSharedFileManager.defaultGroupId) {
        // Notifies on the addition of a new pipe
        self.listener = listener

        self.fileManager = XyoSharedFileManager(
            for: Constants.filename,
            groupIdentifier: groupIdentifier)

//        // The app's id, used for proper file naming and future whitelisting
//        self.bundleIdentifier = bundleIdentifier
//
//        // The app group used by both client and server so the request file can be shared
//        self.groupIdentifier = groupIdentifier
//
//        // Create/open file that is used for requesting pipes
//        let baseUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.groupIdentifier)
//        self.fileUrl = baseUrl?.appendingPathComponent(Constants.filename).appendingPathExtension(Constants.fileExtension)
//
//        // The "server" listens for requests to connect
//        self.listenForConnectionRequest()
    }

    // Called from the client to ask for a pipe to be created for this connection, returning a local pipe
    public func requestConnection(initiationData: [UInt8]?, completion: ((XyoAppGroupPipe?) -> Void)? = nil) {
//        guard
//            let url = self.fileUrl,
//            let initiationData = initiationData else {
//                completion?(nil)
//            return
//        }
//
//        var error: NSError?
//        self.opQueue.addOperation { [weak self] in
//            guard let strong = self else { return }
//
//            // Create the file if it does not exist and write the initiation data
//            let message = Message(bundleIdentifier: strong.bundleIdentifier, initiationData: initiationData)
//            strong.fileCoordinator.coordinate(writingItemAt: url, options: .forReplacing, error: &error) { url in
//                let dictData = NSKeyedArchiver.archivedData(withRootObject: message.encoded)
//                try? dictData.write(to: url)
//
//                // Build the pipe and return it through the completion callback
//                let pipe = XyoAppGroupPipe(
//                    groupIdentifier: XyoAppGroupPipeManager.defaultGroupId,
//                    bundleIdentifier: strong.bundleIdentifier,
//                    manager: strong)
//
//                completion?(pipe)
//            }
//
//            if error != nil { completion?(nil) }
//        }
    }

}

extension XyoAppGroupPipeManager: XyoAppGroupManagerListener {

    // Called when the pipe is released via it's close() method
    public func onClose(bundleIdentifier: String) {
        self.pipes.removeValue(forKey: bundleIdentifier)
    }

}

// MARK: Server listeners for
fileprivate extension XyoAppGroupPipeManager {

    func listenForConnectionRequest(_ data: [UInt8]?) {

    }

    // Called from init()
//    func listenForConnectionRequest() {
//        guard let url = self.fileUrl else { return }
//
//        // Monitor file changes and create the pipe
//        self.monitor = FileMonitor(path: url.path)
//        self.monitor?.onFileEvent = { [weak self] in
//            self?.registerApp(url)
//        }
//    }
//
//    func registerApp(_ url: URL) {
//        guard
//            let containerData = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? Data,
//            let message = Message.decode(containerData),
//            message.bundleIdentifier != self.bundleIdentifier else { return }
//
//        // Create the pipe, setting the initiation data
//        let initiationData = XyoAdvertisePacket(data: message.initiationData)
//        let pipe = self.createPipe(for: message.bundleIdentifier, initiationData: initiationData)
//
//        // Register the pipe
//        self.pipes[message.bundleIdentifier] = pipe
//
//        // Notify listener that the pipe is ready
//        self.listener.onPipe(pipe: pipe)
//    }
//
//    func createPipe(for bundleIdentifier: String, initiationData: XyoAdvertisePacket? = nil) -> XyoAppGroupPipe {
//        return XyoAppGroupPipe(groupIdentifier: self.groupIdentifier, bundleIdentifier: bundleIdentifier, manager: self, initiationData: initiationData)
//    }

}
