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

    fileprivate weak var manager: XyoAppGroupManagerListener?

    fileprivate var completionHandler: SendCompletionHandler?

    fileprivate let initiationData : XyoAdvertisePacket?

    fileprivate let fileManager: XyoSharedFileManager?

    public init(groupIdentifier: String, bundleIdentifier: String, manager: XyoAppGroupManagerListener, initiationData : XyoAdvertisePacket? = nil) {
        self.initiationData = initiationData
        self.fileManager = XyoSharedFileManager(for: bundleIdentifier, groupIdentifier: groupIdentifier)
        self.fileManager?.setReadListenter(self.listenForResponse)


//        // Group ID mus tbe the same on both ends of the pipe
//        self.groupIdentifier = groupIdentifier
//
//        // Used for distinct pipe files
//        self.bundleIdentifier = bundleIdentifier
//
//        // Used for closing the connectiong
//        self.manager = manager
//
//        self.initiationData = initiationData
//
//        // Create/open file that is used to transmit the data
//        let baseUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.groupIdentifier)
//        self.fileUrl = baseUrl?.appendingPathComponent(self.bundleIdentifier).appendingPathExtension(Constants.fileExtension)
//
//        // Listen for responses from send() below, using the supplised completion handler
//        self.listenForResponse()
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
        self.fileManager?.write(data: data) { error in
            guard error == nil else {
                completion(nil)
                return
            }
        }

        self.completionHandler = completion

//        guard let url = self.fileUrl else {
//            completion(nil)
//            return
//        }
//
//        // Set the response handler
//        self.completionHandler = completion
//
//        var error: NSError?
//        self.opQueue.addOperation { [weak self] in
//            guard let strong = self else { return }
//
//            // Create the message with the data and write to the file
//            let message = Message(data: data, bundleIdentifier: strong.bundleIdentifier)
//            strong.fileCoordinator.coordinate(writingItemAt: url, options: .forReplacing, error: &error) { url in
//                let dictData = NSKeyedArchiver.archivedData(withRootObject: message.encoded)
//                try? dictData.write(to: url)
//            }
//
//            if error != nil { completion(nil) }
//        }
    }

    public func close() {
//        self.manager?.onClose(bundleIdentifier: self.bundleIdentifier)
    }

}

// MARK: Handles the response from the other side of the pipe
fileprivate extension XyoAppGroupPipe {

    func listenForResponse(_ data: [UInt8]?) {
        self.completionHandler?(data)
    }

//    // Called from init()
//    func listenForResponse() {
//        guard let url = self.fileUrl else { return }
//
//        // Monitor file changes and emit the event on changes
//        self.monitor = FileMonitor(path: url.path)
//        self.monitor?.onFileEvent = { [weak self] in
//            self?.unpackAndRespond(url)
//        }
//    }
//
//    func unpackAndRespond(_ url: URL) {
//        guard
//            let containerData = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? Data,
//            let message = Message.decode(containerData),
//            message.bundleIdentifier != self.bundleIdentifier else { return }
//
//        self.completionHandler?(message.data)
//    }

}
