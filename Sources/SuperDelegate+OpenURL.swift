
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
    @warn_unused_result
    func canOpenLaunchURL(launchURLToOpen: URLToOpen) -> Bool
    
    /// Called when your application has been asked to open a URL. Will not be called for URLs that were delivered to the app via loadInterfaceWithLaunchItem(_:).
    /// @return Whether the URL was handled.
    @warn_unused_result
    func handleURLToOpen(urlToOpen: URLToOpen) -> Bool
}


// MARK: - URLToOpen


public struct URLToOpen: CustomStringConvertible, Equatable {
    /// The URL to open.
    public let url: NSURL
    /// The Bundle ID of the orgininating application.
    public let sourceApplicationBundleID: String?
    /// A property list object supplied by the source app to communicate information to the receiving app.
    public let annotation: AnyObject?
    /// Set to true if the file needs to be copied before use.
    public let copyBeforeUse: Bool
    
    public init(url: NSURL, sourceApplicationBundleID: String? = nil, annotation: AnyObject? = nil, copyBeforeUse: Bool = false) {
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


// MARK: Equatable


@warn_unused_result
public func ==(lhs: URLToOpen, rhs: URLToOpen) -> Bool {
    return lhs.url == rhs.url
        && lhs.sourceApplicationBundleID == rhs.sourceApplicationBundleID
        && lhs.copyBeforeUse == rhs.copyBeforeUse
    // Unfortuantely we don't know .annotation's Type or whether it is Equatable so we can't use it here.
}


// MARK: - SuperDelegate Open URL Extension


extension SuperDelegate {
    
    
    // MARK: UIApplicationDelegate
    
    
    @available(iOS 9.0, *)
    @warn_unused_result
    final public func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        guard let openURLCapableSelf = self as? OpenURLCapable else {
            noteImproperAPIUsage("Received openURL action but \(self) does not conform to OpenURLCapable. Ignoring.")
            return false
        }
        
        guard launchOptionsURLToOpen != url else {
            // Bail out. We've already processed this URL.
            return true
        }
        
        let sourceApplicationBundleID = options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String
        let annotation = options[UIApplicationOpenURLOptionsAnnotationKey]
        let copyBeforeUse = options[UIApplicationOpenURLOptionsOpenInPlaceKey] as? Bool ?? false
        let urlToOpen = URLToOpen(url: url, sourceApplicationBundleID: sourceApplicationBundleID, annotation: annotation, copyBeforeUse: copyBeforeUse)
        
        return openURLCapableSelf.handleURLToOpen(urlToOpen)
    }
    
    @warn_unused_result
    final public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        guard let openURLCapableSelf = self as? OpenURLCapable else {
            noteImproperAPIUsage("Received openURL action but \(self) does not conform to OpenURLCapable. Ignoring.")
            return false
        }
        
        guard launchOptionsURLToOpen != url else {
            // Bail out. We've already processed this URL.
            return true
        }
        
        let urlToOpen = URLToOpen(url: url, sourceApplicationBundleID: sourceApplication, annotation: annotation, copyBeforeUse: false)
        
        return openURLCapableSelf.handleURLToOpen(urlToOpen)
    }
    
    @warn_unused_result
    final public func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        // Nothing to do here. On iOS 8, application(_:openURL:sourceApplication:annotation:) will be called instead of this one. This method is declared to prevent subclasses from improperly adopting this API.
        return false
    }
    
}
