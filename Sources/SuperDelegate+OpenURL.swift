
//
//  SuperDelegate+OpenURL.swift
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


// MARK: - OpenURLCapable – Opting into this protocl gives your app the ability to handle UserActivity handoff events.


public protocol OpenURLCapable: ApplicationLaunched {
    /// Called when your application has been launched due to a URL.
    /// @return Whether the URL can be handled from a cold start.
    func canOpen(launchURL: URLToOpen) -> Bool
    
    /// Called when your application has been asked to open a URL. Will not be called for URLs that were delivered to the app via loadInterface(launchItem:).
    /// @return Whether the URL was handled.
    func handle(urlToOpen: URLToOpen) -> Bool
}


// MARK: - URLToOpen


public struct URLToOpen: CustomStringConvertible, Equatable {
    /// The URL to open.
    public let url: URL
    /// The Bundle ID of the orgininating application.
    public let sourceApplicationBundleID: String?
    /// A property list object supplied by the source app to communicate information to the receiving app.
    public let annotation: Any?
    /// Set to true if the file needs to be copied before use.
    public let copyBeforeUse: Bool
    
    // MARK: Equatable
    
    public static func ==(lhs: URLToOpen, rhs: URLToOpen) -> Bool {
        return lhs.url == rhs.url
            && lhs.sourceApplicationBundleID == rhs.sourceApplicationBundleID
            && lhs.copyBeforeUse == rhs.copyBeforeUse
        // Unfortuantely we don't know .annotation's Type or whether it is Equatable so we can't use it here.
    }
    
    // MARK: Initialization
    
    public init(url: URL, sourceApplicationBundleID: String? = nil, annotation: Any? = nil, copyBeforeUse: Bool = false) {
        self.url = url
        self.sourceApplicationBundleID = sourceApplicationBundleID
        self.annotation = annotation
        self.copyBeforeUse = copyBeforeUse
    }
    
    // MARK: CustomStringConvertible
    
    public var description: String {
        return url.description
    }
}


// MARK: - SuperDelegate Open URL Extension


extension SuperDelegate {
    
    
    // MARK: UIApplicationDelegate
    
    
    @objc(application:openURL:options:)
    @available(iOS 9.0, *)
    final public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let openURLCapableSelf = self as? OpenURLCapable else {
            noteImproperAPIUsage("Received openURL action but \(self) does not conform to OpenURLCapable. Ignoring.")
            return false
        }
        
        guard launchOptionsURLToOpen != url else {
            // Bail out. We've already processed this URL.
            return true
        }
        
        let sourceApplicationBundleID = options[.sourceApplication] as? String
        let annotation = options[.annotation]
        let copyBeforeUse = options[.openInPlace] as? Bool ?? false
        let urlToOpen = URLToOpen(url: url, sourceApplicationBundleID: sourceApplicationBundleID, annotation: annotation, copyBeforeUse: copyBeforeUse)
        
        return openURLCapableSelf.handle(urlToOpen: urlToOpen)
    }
    
    @objc(application:openURL:sourceApplication:annotation:)
    final public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        guard let openURLCapableSelf = self as? OpenURLCapable else {
            noteImproperAPIUsage("Received openURL action but \(self) does not conform to OpenURLCapable. Ignoring.")
            return false
        }
        
        guard launchOptionsURLToOpen != url else {
            // Bail out. We've already processed this URL.
            return true
        }
        
        let urlToOpen = URLToOpen(url: url, sourceApplicationBundleID: sourceApplication, annotation: annotation, copyBeforeUse: false)
        
        return openURLCapableSelf.handle(urlToOpen: urlToOpen)
    }
    
    @objc(application:handleOpenURL:)
    final public func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        // Nothing to do here. On iOS 8, application(_:open:sourceApplication:annotation:) will be called instead of this one. This method is declared to prevent subclasses from improperly adopting this API.
        return false
    }
}


// MARK: – UIApplicationLaunchOptionsKey Extension


extension UIApplicationLaunchOptionsKey {
    
    // UIApplicationLaunchOptionsKey.openInPlace can be passed into launchOptions, but the Swift 3 API doesn't acknowledge this. So we add it here manually.
    @available(iOS 9.0, *)
    public static let openInPlace = UIApplicationLaunchOptionsKey(rawValue: "UIApplicationOpenURLOptionsOpenInPlaceKey")
}
