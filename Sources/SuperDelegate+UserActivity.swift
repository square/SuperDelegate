//
//  SuperDelegate+UserActivity.swift
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


// MARK: - UserActivityCapable – Opting into this protocl gives your app the ability to handle UserActivity (Spotlight and Associated Domain) events.


public protocol UserActivityCapable: ApplicationLaunched {
    /// Called whenever your application must handle a user activity.
    /// @return Whether you can handle the user activity. Returning false means the below methods will not be called.
    func canResume(userActivity: NSUserActivity) -> Bool
    
    /// Called whenever your application must continue a user activity after the interface has been loaded.
    /// @return true if your app handled the user activity, false if it did not.
    func resume(userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Swift.Void) -> Bool
}


// MARK: - SuperDelegate User Activity Extension


extension SuperDelegate {
    
    
    // MARK: UIApplicationDelegate
    
    
    @objc(application:continueUserActivity:restorationHandler:)
    final public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Swift.Void) -> Bool {
        guard let userActivityCapableSelf = self as? UserActivityCapable else {
            noteImproperAPIUsage("Received continueUserActivity but \(self) does not conform to UserActivityCapable. Not handling user activity event.")
            return false
        }
        
        guard launchOptionsUserActivity !== userActivity else {
            // Bail out. We've already processed this user activity.
            return true
        }
        
        guard userActivityCapableSelf.canResume(userActivity: userActivity) else {
            return false
        }
        
        return userActivityCapableSelf.resume(userActivity: userActivity, restorationHandler: restorationHandler)
    }
    
}


// MARK: – UIApplicationLaunchOptionsKey Extension


extension UIApplicationLaunchOptionsKey {
    
    // UIApplicationLaunchOptionsKey.userActivity is passed into launchOptions, but the API doesn't acknowledge this. So we add it here manually.
    public static let userActivity = UIApplicationLaunchOptionsKey(rawValue: "UIApplicationLaunchOptionsUserActivityKey")
}
