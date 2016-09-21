//
//  SuperDelegate+Handoff.swift
//  SuperDelegate
//
//  Created by Dan Federman on 4/26/16.
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


// MARK: - HandoffCapable – Opting into this protocl gives your app the ability to handle Handoff events.


public protocol HandoffCapable: UserActivityCapable {
    /// Called whenever your application takes responsibility for notifying users when a continuation activity takes longer than expected. Use this method to provide immediate feedback to the user that an activity is about to continue on this device. The app calls this method as soon as the user confirms that an activity should be continued but possibly before the data associated with that activity is available.
    /// @return true if you want to notify the user that a continuation is in progress or false if you want iOS to notify the user.
    func willContinue(userActivityType: String) -> Bool
    
    /// Called whenever a user activity item managed by UIKit has been updated.
    func didUpdate(userActivity: NSUserActivity)
    
    /// Called whenever iOS failed to continue a user activity.
    func didFailToContinue(userActivityType: String, error: Error)
}


// MARK: - SuperDelegate Handoff Extension


extension SuperDelegate {
    
    
    // MARK: UIApplicationDelegate
    
    
    final public func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        guard let userActivityCapableSelf = self as? HandoffCapable else {
            noteImproperAPIUsage("Received willContinueUserActivityWithType but \(self) does not conform to HandoffCapable. Not handling handoff event.")
            return false
        }
        
        return userActivityCapableSelf.willContinue(userActivityType: userActivityType)
    }
    
    @objc(application:didUpdateUserActivity:)
    final public func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        guard let userActivityCapableSelf = self as? HandoffCapable else {
            noteImproperAPIUsage("Received didUpdateUserActivity but \(self) does not conform to HandoffCapable. Not handling handoff event.")
            return
        }
        
        userActivityCapableSelf.didUpdate(userActivity: userActivity)
    }
    
    final public func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        guard let userActivityCapableSelf = self as? HandoffCapable else {
            noteImproperAPIUsage("Received didFailToContinueUserActivityWithType but \(self) does not conform to HandoffCapable. Not handling handoff event.")
            return
        }
        
        userActivityCapableSelf.didFailToContinue(userActivityType: userActivityType, error: error)
    }
}
