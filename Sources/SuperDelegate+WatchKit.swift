//
//  SuperDelegate+WatchKit.swift
//  SuperDelegate
//
//  Created by Dan Federman on 4/17/16.
//  Copyright © 2016 Square, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation


// MARK: WatchKitCapable – Opting into this protocl gives your app the ability to handle WatchKit extension requests.


public protocol WatchKitCapable: ApplicationLaunched {
    /// Called when your app receives a request from the WatchKit extension
    func handleWatchKitExtensionRequest(userInfo: [AnyHashable : Any]?, reply: @escaping ([AnyHashable : Any]?) -> Swift.Void)
}


// MARK: - SuperDelegate WatchKit Extension


extension SuperDelegate {
    
    
    // MARK: UIApplicationDelegate
    
    
    final public func application(_ application: UIApplication, handleWatchKitExtensionRequest userInfo: [AnyHashable : Any]?, reply: @escaping ([AnyHashable : Any]?) -> Swift.Void) {
        guard let watchKitCapableSelf = self as? WatchKitCapable else {
            noteImproperAPIUsage("Received WatchKit extension request but \(self) does not conform to WatchKitCapable. Ignoring.")
            reply(nil)
            return
        }
        
        // iOS 8.4 calls application(_:handleWatchKitExtensionRequest:userInfo:reply:) prior to the application finishing launching. Make sure our application is set up once.
        setupApplicationOnce()
        
        watchKitCapableSelf.handleWatchKitExtensionRequest(userInfo: userInfo, reply: reply)
    }
}
