//
//  XyoSharedFileManager.swift
//  sdk-core-swift
//
//  Created by Darren Sutherland on 6/1/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public class XyoSharedFileManager {

    internal typealias WriteCallback = (NSError?) -> Void
    internal typealias ReadCallback = ([UInt8]?) -> ()

    public static let defaultGroupId = "group.network.xyo"

    fileprivate let fileCoordinator = NSFileCoordinator()
    fileprivate let opQueue = OperationQueue()

    fileprivate var monitor: FileMonitor?

    fileprivate struct Constants {
        static let fileExtension = "xyonetwork"
    }

    fileprivate let identifier: String
    fileprivate let groupIdentifier: String

    fileprivate let url: URL

    internal var readCallback: ReadCallback?

    init?(for identifier: String, groupIdentifier: String = XyoSharedFileManager.defaultGroupId) {
        self.identifier = identifier
        self.groupIdentifier = groupIdentifier

        guard let baseUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.groupIdentifier) else { return nil }
        self.url = baseUrl.appendingPathComponent(identifier).appendingPathExtension(Constants.fileExtension)

        self.listenForRead()
    }

    deinit {
        self.fileCoordinator.cancel()
        self.opQueue.cancelAllOperations()
    }

    func setReadListenter(_ readCallback: ReadCallback?) {
        self.readCallback = readCallback
    }
}

internal extension XyoSharedFileManager {

    // Send data to the defined file
    func write(data: [UInt8], callback: WriteCallback? = nil) {
        let message = Message(data: data, identifier: self.identifier)

        var error: NSError?
        self.opQueue.addOperation { [weak self] in
            guard let strong = self else { return }

            // Create the message with the data and write to the file
            strong.fileCoordinator.coordinate(writingItemAt: strong.url, options: .forReplacing, error: &error) { url in
                let dictData = NSKeyedArchiver.archivedData(withRootObject: message.encoded)
                try? dictData.write(to: url)
                callback?(nil)
            }

            if error != nil { callback?(error) }
        }
    }

    // Handles changes to the file
    func listenForRead() {
        // Monitor file changes and create the pipe
        self.monitor = FileMonitor(path: url.path)
        self.monitor?.onFileEvent = { [weak self] in
            self?.validateRead()
        }
    }

    // Unpacks the file change and returns the message data, ensuring the sender is not the same
    func validateRead() {
        guard
            let containerData = NSKeyedUnarchiver.unarchiveObject(withFile: self.url.path) as? Data,
            let message = Message.decode(containerData),
            message.identifier != self.identifier else { return }

        self.readCallback?(message.data)
    }
}

// MARK: Message payload, serializable
internal extension XyoSharedFileManager {

    struct Message: Codable {
        let data: [UInt8], identifier: String

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

/// Watches the file so it can transmit data to other listeners
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
            if onFileEvent != nil {
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
