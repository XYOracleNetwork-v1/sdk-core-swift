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
    func onClose (identifier : String?)
}

/// Allows for a client to request a pipe be created to connect to a server
public class XyoAppGroupPipeServer {

    // Registry of pipes
    fileprivate lazy var pipes = [String: XyoAppGroupPipe]()

    fileprivate struct Constants {
        static let filename = "appgrouprequest"
        static let fileExtension = "xyonetwork"
        static let serverIdentifier = "server"
    }

    fileprivate let listener: XyoAppGroupPipeListener

    fileprivate let fileManager: XyoSharedFileManager?

    fileprivate let groupIdentifier: String

    public init(listener: XyoAppGroupPipeListener, isServer: Bool = false, groupIdentifier: String = XyoSharedFileManager.defaultGroupId) {
        self.groupIdentifier = groupIdentifier

        // Notifies on the addition of a new pipe
        self.listener = listener

        self.fileManager = XyoSharedFileManager(
            for: Constants.filename,
            filename: Constants.filename,
            allowsBackgroundExecution: isServer,
            groupIdentifier: groupIdentifier)

        // The "server" listens for requests to connect
        if isServer {
            self.fileManager?.setReadListenter(self.receivedRequest)
        }
    }

    // Called from the client to ask for a pipe to be created for this connection, returning a local pipe
    public func requestConnection(identifier: String) -> XyoAppGroupPipe {
        // Build the pipe and return it through the completion callback
        let pipe = XyoAppGroupPipe(
            groupIdentifier: self.groupIdentifier,
            identifier: identifier,
            pipeName: identifier,
            manager: self,
            requestorIdentifier: identifier)

        self.pipes[identifier] = pipe

        // Write out the request to a file so the server can pick it up
        self.fileManager?.write(data: [0x01], withIdentifier: identifier)

        return pipe
    }

}

extension XyoAppGroupPipeServer: XyoAppGroupManagerListener {

    // Called when the pipe is released via it's close() method
    public func onClose(identifier: String?) {
        guard let identifier = identifier else { return }
        self.pipes.removeValue(forKey: identifier)
    }

}

// MARK: Server listeners for
fileprivate extension XyoAppGroupPipeServer {

    // Used by the "server" to create a matching pipe
    func receivedRequest(messageData: [UInt8]?, identifier: String) {
        guard self.pipes[identifier] == nil else { return }

        // Build the pipe for talking to the client
        let pipe = XyoAppGroupPipe(
            groupIdentifier: self.groupIdentifier,
            identifier: Constants.serverIdentifier,
            pipeName: identifier,
            manager: self,
            requestorIdentifier: identifier)

        // Track the pipe
        self.pipes[identifier] = pipe

        // Notify the listener
        self.listener.onPipe(pipe: pipe)
    }

}
