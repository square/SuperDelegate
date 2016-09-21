//
//  SuperDelegate+StateRestoration.swift
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


// MARK StateRestorationCapable – Opting into this protocol gives your app the ability to handle application state restoration.


public protocol StateRestorationCapable: ApplicationLaunched {
    /// Called when your app can save its application state for restoration. Returns whether the app should save the current state.
    func shouldSaveApplicationState(using coder: NSCoder) -> Bool
    
    /// Called when your app can restore its application state after its interface has been loaded. Returns whether the app should restore.
    func shouldRestoreApplicationState(using coder: NSCoder) -> Bool
    
    /// Tells your delegate to save any high-level state information at the beginning of the state preservation process.
    func willEncodeRestorableState(using coder: NSCoder)
    
    /// Tells your delegate to restore any high-level state information as part of the state restoration process.
    func didDecodeRestorableState(using coder: NSCoder)
    
    /// Asks your app to provide the specified view controller during state restoration.
    func viewControllerWithRestorationIdentifierPath(identifierComponents: [Any], coder: NSCoder) -> UIViewController?
}


// MARK: - SuperDelegate State Restoration Extension


extension SuperDelegate {
    
    
    // MARK: UIApplicationDelegate
    
    
    final public func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        guard let stateRestorationCapableSelf = self as? StateRestorationCapable else {
            // Nothing to do here.
            return false
        }
        
        return stateRestorationCapableSelf.shouldSaveApplicationState(using: coder)
    }
    
    final public func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        guard let stateRestorationCapableSelf = self as? StateRestorationCapable else {
            // Nothing to do here.
            return false
        }
        
        return stateRestorationCapableSelf.shouldRestoreApplicationState(using: coder)
    }
    
    @objc(application:willEncodeRestorableStateWithCoder:)
    final public func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder) {
        guard let stateRestorationCapableSelf = self as? StateRestorationCapable else {
            // Nothing to do here.
            return
        }
        
        stateRestorationCapableSelf.willEncodeRestorableState(using: coder)
    }
    
    @objc(application:didDecodeRestorableStateWithCoder:)
    final public func application(_ application: UIApplication, didDecodeRestorableStateWith coder: NSCoder) {
        guard let stateRestorationCapableSelf = self as? StateRestorationCapable else {
            // Nothing to do here.
            return
        }
        
        stateRestorationCapableSelf.didDecodeRestorableState(using: coder)
        
    }
    
    final public func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [Any], coder: NSCoder) -> UIViewController? {
        guard let stateRestorationCapableSelf = self as? StateRestorationCapable else {
            noteImproperAPIUsage("Received viewControllerWithRestorationIdentifierPath but \(self) does not conform to StateRestorationCapable. Not handling state restoration event.")
            return nil
        }
        
        return stateRestorationCapableSelf.viewControllerWithRestorationIdentifierPath(identifierComponents: identifierComponents, coder: coder)
    }
}
