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

    public static let defaultGroupId = "group.network.xyo"

    fileprivate lazy var pipes = [String: XyoAppGroupPipe]()

    fileprivate let groupIdentifier: String

    fileprivate let fileCoordinator = NSFileCoordinator()
    fileprivate let opQueue = OperationQueue()

    fileprivate let fileUrl: URL?
    fileprivate var monitor: FileMonitor?

    fileprivate let bundleIdentifier: String

    fileprivate struct Constants {
        static let filename = "appgrouprequest"
        static let fileExtension = "xyonetwork"
    }

    fileprivate let listener: XyoAppGroupPipeListener

    init(listener: XyoAppGroupPipeListener, bundleIdentifier: String, groupIdentifier: String = XyoAppGroupPipeManager.defaultGroupId) {
        // Notifies on the addition of a new pipe
        self.listener = listener

        // The app's id, used for proper file naming and future whitelisting
        self.bundleIdentifier = bundleIdentifier

        // The app group used by both client and server so the request file can be shared
        self.groupIdentifier = groupIdentifier

        // Create/open file that is used for requesting pipes
        let baseUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.groupIdentifier)
        self.fileUrl = baseUrl?.appendingPathComponent(Constants.filename).appendingPathExtension(Constants.fileExtension)

        // The "server" listens for requests to connect
        self.listenForConnectionRequest()
    }

    // Called from the client to ask for a pipe to be created for this connection
    // A nil-error response indicates the
    func requestConnection(bundleIdentifier: String, initiationData: [UInt8]?, completion: ((Error?) -> Void)? = nil) {
        guard
            let url = self.fileUrl,
            let initiationData = initiationData else {
                completion?(nil)
            return
        }

        var error: NSError?
        self.opQueue.addOperation { [weak self] in
            guard let strong = self else { return }

            // Create the message with the data and write to the file
            let message = Message(bundleIdentifier: bundleIdentifier, initiationData: initiationData)
            strong.fileCoordinator.coordinate(writingItemAt: url, options: .forReplacing, error: &error) { url in
                let dictData = NSKeyedArchiver.archivedData(withRootObject: message.encoded)
                try? dictData.write(to: url)
            }

            if error != nil { completion?(error) }
        }
    }

}

extension XyoAppGroupPipeManager: XyoAppGroupManagerListener {

    public func onClose(bundleIdentifier: String) {
        self.pipes.removeValue(forKey: bundleIdentifier)

        // TODO remove file
    }

}

// MARK: Simple serializable container to store the data + sender id
fileprivate extension XyoAppGroupPipeManager {

    struct Message: Codable {
        let bundleIdentifier: String, initiationData: [UInt8]

        var encoded: Data? {
            let encoder = JSONEncoder()
            let jsonData = try? encoder.encode(self)
            return jsonData
        }

        static func decode(_ data: Data) -> Message? {
            let decoder = JSONDecoder()
            let decoded = try? decoder.decode(Message.self, from: data)
            return decoded
        }
    }

}

// MARK: Server listeners for
fileprivate extension XyoAppGroupPipeManager {

    // Called from init()
    func listenForConnectionRequest() {
        guard let url = self.fileUrl else { return }

        // Monitor file changes and create the pipe
        self.monitor = FileMonitor(path: url.path)
        self.monitor?.onFileEvent = { [weak self] in
            self?.registerApp(url)
        }
    }

    func registerApp(_ url: URL) {
        guard
            let containerData = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? Data,
            let message = Message.decode(containerData),
            message.bundleIdentifier != self.bundleIdentifier else { return }

        // Create the pipe, setting the initiation data
        let initiationData = XyoAdvertisePacket(data: message.initiationData)
        let pipe = self.createPipe(for: message.bundleIdentifier, initiationData: initiationData)
        self.pipes[message.bundleIdentifier] = pipe
        self.listener.onPipe(pipe: pipe)
    }

    func createPipe(for bundleIdentifier: String, initiationData: XyoAdvertisePacket? = nil) -> XyoAppGroupPipe {
        return XyoAppGroupPipe(groupIdentifier: self.groupIdentifier, bundleIdentifier: bundleIdentifier, manager: self, initiationData: initiationData)
    }

}
