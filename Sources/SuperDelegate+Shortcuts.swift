//
//  SuperDelegate+Shortcuts.swift
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


// MARK: ShortcutCapable – Opting into this protocol gives your app the ability to handle force-press shortcuts from the home screen.


@available(iOS 9.0, *)
public protocol ShortcutCapable: ApplicationLaunched {
    /// Called whenever iOS informs SuperDelgate of a UIApplicationShortItem to process. Guaranteed to be called after setupApplication().
    func canHandle(shortcutItem: UIApplicationShortcutItem) -> Bool
    
    /// Called when your app receives a shortcut item. Will not be called for shortcuts that were delivered to the app via loadInterface(launchItem:). Guaranteed not to be called with a shortcut item your app can not handle. Execute completionHandler when your application has handled the shortcut.
    func handle(shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping () -> Swift.Void)
}


// MARK: - SuperDelegate Shortcuts Extension


extension SuperDelegate {
    
    
    // MARK: UIApplicationDelegate
    
    
    @objc(application:performActionForShortcutItem:completionHandler:)
    @available(iOS 9.0, *)
    final public func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Swift.Void) {
        guard let shortcutCapableSelf = self as? ShortcutCapable else {
            noteImproperAPIUsage("Received shortcut item but \(self) does not conform to ShortcutCapable. Ignoring.")
            completionHandler(false)
            return
        }
        
        let canHandleShortcutItem = shortcutCapableSelf.canHandle(shortcutItem: shortcutItem)
        
        if canHandleShortcutItem {
            shortcutCapableSelf.handle(shortcutItem: shortcutItem) {
                // Since we know the app can handle the shortcut item, we can assume handling it was successful.
                completionHandler(true)
            }
        }
    }
}
