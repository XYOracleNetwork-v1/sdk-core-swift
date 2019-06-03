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

    fileprivate let groupIdentifier: String

    public init(listener: XyoAppGroupPipeListener, groupIdentifier: String = XyoSharedFileManager.defaultGroupId) {
        self.groupIdentifier = groupIdentifier

        // Notifies on the addition of a new pipe
        self.listener = listener

        self.fileManager = XyoSharedFileManager(
            for: Constants.filename,
            groupIdentifier: groupIdentifier)

        // The "server" listens for requests to connect
        self.fileManager?.setReadListenter(self.receivedRequest)
    }

    // Called from the client to ask for a pipe to be created for this connection, returning a local pipe
    public func requestConnection(initiationData: [UInt8]?, bundleIdentifier: String, completion: ((XyoAppGroupPipe?) -> Void)? = nil) {
        guard let initiationData = initiationData else {
            completion?(nil)
            return
        }

        // Build the pipe and return it through the completion callback
        let pipe = XyoAppGroupPipe(
            groupIdentifier: self.groupIdentifier,
            bundleIdentifier: bundleIdentifier,
            manager: self)

        // Write out the request to a file so the server can pick it up
        self.fileManager?.write(data: initiationData, withIdentifier: bundleIdentifier)

        // Return the pipe
        completion?(pipe)
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

    // Used by the "server" to create a matching pipe
    func receivedRequest(messageData: [UInt8]?, identifier: String) {
        // Build the pipe for talking to the client
        let pipe = XyoAppGroupPipe(
            groupIdentifier: self.groupIdentifier,
            bundleIdentifier: identifier,
            manager: self)

        // Track the pipe
        self.pipes[identifier] = pipe

        // Notify the listener
        self.listener.onPipe(pipe: pipe)
    }

}
