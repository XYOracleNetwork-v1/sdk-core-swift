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

    public typealias SendCompletionHandler = ([UInt8]?) -> ()

    // The connection wrangler, a ref is saved to be used when the pipe closes
    fileprivate weak var manager: XyoAppGroupManagerListener?

    // The return handler for the pipe
    fileprivate var completionHandler: SendCompletionHandler? {
        didSet {
            print("handler was set")
        }
    }

    // Initial data
    fileprivate let initiationData : XyoAdvertisePacket?

    // Handles file management so inter-app communication can occur
    fileprivate let fileManager: XyoSharedFileManager?

    // The identifier of the app, used as the filename for the pipe
    fileprivate let bundleIdentifier: String

    public init(groupIdentifier: String, identifier: String, pipeName: String, manager: XyoAppGroupManagerListener, initiationData : XyoAdvertisePacket? = nil) {
        self.initiationData = initiationData
        self.bundleIdentifier = identifier

        // Create the filemanager and listen for write changes to the pipe file
        self.fileManager = XyoSharedFileManager(for: identifier, filename: pipeName, groupIdentifier: groupIdentifier)
        self.fileManager?.setReadListenter(self.listenForResponse)
    }

    public func setCompletionHandler(_ handler: SendCompletionHandler?) {
        self.completionHandler = handler
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
        // Write to the pipe file, which will trigger the
        self.fileManager?.write(data: data) { error in
            guard error == nil else {
                completion(nil)
                return
            }
        }

        // Set the completion handler for the response
        self.completionHandler = completion
    }

    public func close() {
        self.manager?.onClose(bundleIdentifier: self.bundleIdentifier)
    }

}

// MARK: Handles the response from the other side of the pipe
fileprivate extension XyoAppGroupPipe {

    func listenForResponse(_ data: [UInt8]?, identifier: String) {
        // The pipe file has been written to, so we callback with the result
        // The filemanager ensures that this is not fired when the same side writes
        self.completionHandler?(data)
    }

}
