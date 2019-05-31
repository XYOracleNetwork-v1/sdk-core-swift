//
//  XyoAppGroupPipe.swift
//  sdk-core-swift
//
//  Created by Darren Sutherland on 5/31/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

/// Uses a shared file between the same app group to transmit data between apps
public class XyoAppGroupPipe {

    typealias SendCompletionHandler = ([UInt8]?) -> ()

    fileprivate let groupIdentifier: String

    fileprivate struct Constants {
        static let filename = "whatever"
        static let fileExtension = "xyonetwork"
    }

    fileprivate let bundleIdentifier: String

    fileprivate let fileCoordinator = NSFileCoordinator()
    fileprivate let opQueue = OperationQueue()

    fileprivate let fileUrl: URL?

    fileprivate var monitor: FileMonitor?

    fileprivate weak var manager: XyoAppGroupManagerListener?

    fileprivate var completionHandler: SendCompletionHandler?

    fileprivate let initiationData : XyoAdvertisePacket?

    public init(groupIdentifier: String, bundleIdentifier: String, manager: XyoAppGroupManagerListener, initiationData : XyoAdvertisePacket? = nil) {
        // Group ID mus tbe the same on both ends of the pipe
        self.groupIdentifier = groupIdentifier

        // Used for distinct pipe files
        self.bundleIdentifier = bundleIdentifier

        // Used for closing the connectiong
        self.manager = manager

        self.initiationData = initiationData

        // Create/open file that is used to transmit the data
        let baseUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.groupIdentifier)
        self.fileUrl = baseUrl?.appendingPathComponent(self.bundleIdentifier).appendingPathExtension(Constants.fileExtension)

        // Listen for responses from send() below, using the supplised completion handler
        self.listenForResponse()
    }

    deinit {
        self.fileCoordinator.cancel()
        self.opQueue.cancelAllOperations()
    }

}

// MARK: XyoNetworkPipe
extension XyoAppGroupPipe: XyoNetworkPipe {

    public func getInitiationData() -> XyoAdvertisePacket? {
        return initiationData
    }

    public func getNetworkHuerestics() -> [XyoObjectStructure] {
        return []
    }

    public func send(data: [UInt8], waitForResponse: Bool, completion: @escaping ([UInt8]?) -> ()) {
        guard let url = self.fileUrl else {
            completion(nil)
            return
        }

        // Set the response handler
        self.completionHandler = completion

        var error: NSError?
        self.opQueue.addOperation { [weak self] in
            guard let strong = self else { return }

            // Create the message with the data and write to the file
            let message = Message(data: data, bundleIdentifier: strong.bundleIdentifier)
            strong.fileCoordinator.coordinate(writingItemAt: url, options: .forReplacing, error: &error) { url in
                let dictData = NSKeyedArchiver.archivedData(withRootObject: message.encoded)
                try? dictData.write(to: url)
            }

            if error != nil { completion(nil) }
        }
    }

    public func close() {
        self.manager?.onClose(bundleIdentifier: self.bundleIdentifier)
    }

}

// MARK: Handles the response from the other side of the pipe
fileprivate extension XyoAppGroupPipe {

    // Called from init()
    func listenForResponse() {
        guard let url = self.fileUrl else { return }

        // Monitor file changes and emit the event on changes
        self.monitor = FileMonitor(path: url.path)
        self.monitor?.onFileEvent = { [weak self] in
            self?.unpackAndRespond(url)
        }
    }

    func unpackAndRespond(_ url: URL) {
        guard
            let containerData = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? Data,
            let message = Message.decode(containerData),
            message.bundleIdentifier != self.bundleIdentifier else { return }

        self.completionHandler?(message.data)
    }

}

// MARK: Simple serializable container to store the data + sender id
fileprivate extension XyoAppGroupPipe {

    struct Message: Codable {
        let data: [UInt8], bundleIdentifier: String

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

// Watches the file so it can transmit data to other listeners
internal class FileMonitor {

    private let filePath: String
    private let fileSystemEvent: DispatchSource.FileSystemEvent
    private let dispatchQueue: DispatchQueue

    private var eventSource: DispatchSourceFileSystemObject?

    internal var onFileEvent: (() -> ())? {
        willSet {
            self.eventSource?.cancel()
        }
        didSet {
            if (onFileEvent != nil) {
                self.startObservingFileChanges()
            }
        }
    }

    internal init?(path: String,
                   observeEvent: DispatchSource.FileSystemEvent = .write,
                   queue: DispatchQueue = DispatchQueue.global(),
                   createFile create: Bool = true) {

        self.filePath = path
        self.fileSystemEvent = observeEvent
        self.dispatchQueue = queue

        if self.fileExists() == false && create == false {
            return nil
        } else if self.fileExists() == false {
            createFile()
        }
    }

    deinit {
        self.eventSource?.cancel()
    }

    private func fileExists() -> Bool {
        return FileManager.default.fileExists(atPath: self.filePath)
    }

    private func createFile() {
        if self.fileExists() == false {
            FileManager.default.createFile(atPath: self.filePath, contents: nil, attributes: nil)
        }
    }

    private func startObservingFileChanges() {
        guard self.fileExists() == true else { return }

        let descriptor = open(self.filePath, O_EVTONLY)
        guard descriptor != -1 else { return }

        self.eventSource = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: descriptor,
            eventMask: self.fileSystemEvent,
            queue: self.dispatchQueue)

        self.eventSource?.setEventHandler { [weak self] in
            self?.onFileEvent?()
        }

        self.eventSource?.setCancelHandler() {
            close(descriptor)
        }

        self.eventSource?.resume()
    }

}
