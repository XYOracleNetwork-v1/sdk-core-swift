//
//  XyoAppGroupStorage.swift
//  sdk-core-swift
//
//  Created by Darren Sutherland on 5/30/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

/// Allows for apps in the same app group to listen for new bound witnesses
/// Adapted from https://agostini.tech/2017/08/13/sharing-data-between-applications-and-extensions-using-app-groups/
public class XyoAppGroupPublishManager {

    public typealias XyoAppGroupPublishReceiver = (_ key: [UInt8], _ value: [UInt8]) -> Void
    public typealias XyoAppGroupPublishError = (NSError?) -> Void

    fileprivate struct Constants {
        static let filename = "boundwitness"
        static let fileExtension = "xyonetwork"
    }

    fileprivate let groupIdentifier: String

    fileprivate let fileCoordinator = NSFileCoordinator()
    fileprivate let opQueue = OperationQueue()
    fileprivate let storageId = UUID()

    fileprivate var receiver: XyoAppGroupPublishReceiver?

    fileprivate var monitor: FileMonitor?

    fileprivate let fileUrl: URL

    init?(groupIdentifier: String, receiver: XyoAppGroupPublishReceiver? = nil) {
        self.groupIdentifier = groupIdentifier
        self.receiver = receiver

        // Build the url if valid
        guard
            let baseUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.groupIdentifier)
            else { return nil }

        self.fileUrl = baseUrl.appendingPathComponent(Constants.filename).appendingPathExtension(Constants.fileExtension)
        if self.receiver != nil {
            self.listenForPublishEvents()
        }
    }

    deinit {
        self.fileCoordinator.cancel()
        self.opQueue.cancelAllOperations()
    }

}

// MARK: Simple storage container for a bound witness with the id of the publisher
fileprivate extension XyoAppGroupPublishManager {

    struct StorageContainer: Codable {
        let key: [UInt8], value: [UInt8], senderId: UUID

        var encoded: Data? {
            let encoder = JSONEncoder()
            let jsonData = try? encoder.encode(self)
            return jsonData
        }

        static func decode(_ data: Data) -> StorageContainer? {
            let decoder = JSONDecoder()
            let decoded = try? decoder.decode(StorageContainer.self, from: data)
            return decoded
        }
    }

}

// MARK: Primary entry point to publish a new bound witness to other apps in the group
public extension XyoAppGroupPublishManager {

    func publish(key: [UInt8], value: [UInt8], callback: XyoAppGroupPublishError? = nil) {
        var error: NSError?
        self.opQueue.addOperation { [weak self] in
            guard let strong = self else { return }

            // Create the container for the bound witness data and write to the file
            let container = StorageContainer(key: key, value: value, senderId: strong.storageId)
            strong.fileCoordinator.coordinate(writingItemAt: strong.fileUrl, options: .forReplacing, error: &error) { url in
                let dictData = NSKeyedArchiver.archivedData(withRootObject: container.encoded)
                try? dictData.write(to: url)
                callback?(nil)
            }

            if error != nil { callback?(error) }
        }
    }

}

// MARK: Handles listening to the
fileprivate extension XyoAppGroupPublishManager {

    func listenForPublishEvents() {
        // Auto-emit any event that is still in the queue
        self.emitPublicEvent()

        // Monitor file changes and emit the event on changes
        self.monitor = FileMonitor(path: self.fileUrl.path)
        self.monitor?.onFileEvent = { [weak self] in
            self?.emitPublicEvent()
        }
    }

    func emitPublicEvent() {
        guard
            let containerData = NSKeyedUnarchiver.unarchiveObject(withFile: self.fileUrl.path) as? Data,
            let container = StorageContainer.decode(containerData),
            container.senderId != self.storageId else { return }

        self.receiver?(container.key, container.value)
    }

}

// Watches the file so it can transmit data to other listeners
private class FileMonitor {

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
