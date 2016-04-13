//
//  SuperDelegate+UserNotifications.swift
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


// MARK: UserNotificationCapable – Opting into this protocol gives your app the ability to register for User Notifications. Adopt RemoteNotification or LocalNotification to actually receive notifications.


public protocol UserNotificationCapable: ApplicationLaunched {
    /// Called when your app registers for user notifications.
    @warn_unused_result
    func requestedUserNotificationSettings() -> UIUserNotificationSettings
    
    /// Called every time user notifications are registered. Will happen every time the application is brought to the foreground after requestUserNotificationPermissions is called.
    func didReceiveUserNotificationPermissions(userNotificationPermissionsGranted: UserNotificationPermissionsGranted)
}


// MARK: - UserNotificationPermissionsGranted


public enum UserNotificationPermissionsGranted: Equatable {
    /// None of the permissions detailed in requestedUserNotificationSettings().types are granted.
    case None
    /// Some of the permissions detailed in requestedUserNotificationSettings().types are granted.
    case Some(grantedPermissions: UIUserNotificationType)
    /// All of the permissions detailed in requestedUserNotificationSettings().types are granted.
    case Requested
    
    internal init(grantedPermissions: UIUserNotificationType, preferredPermissions: UIUserNotificationType) {
        if grantedPermissions.rawValue & preferredPermissions.rawValue == preferredPermissions.rawValue {
            self = .Requested
        } else if grantedPermissions.rawValue & preferredPermissions.rawValue != UIUserNotificationType.None.rawValue {
            self = .Some(grantedPermissions: grantedPermissions)
        } else {
            self = .None
        }
    }
}


// MARK: Equatable


@warn_unused_result
public func ==(lhs: UserNotificationPermissionsGranted, rhs: UserNotificationPermissionsGranted) -> Bool {
    switch (lhs, rhs) {
    case (.Requested, .Requested):
        return true
    case let (.Some(lhsGrantedPermissions), .Some(rhsGrantedPermissions)) where lhsGrantedPermissions == rhsGrantedPermissions:
        return true
    case (.None, .None):
        return true
    default:
        return false
    }
}


public enum UserNotificationOrigin {
    /// The user tapped the notification to bring the app to the foreground
    case UserTappedToBringAppToForeground
    /// The user has not seen the notification since it was delivered while the app was in the foreground
    case DeliveredWhileInForground
    /// The user may have seen the notification, but hasn't tapped on it. RemoteNotification
    case DeliveredWhileInBackground
}


// MARK: - SuperDelegate User Notification Extension


extension SuperDelegate {
    
    
    // MARK: Public Methods
    
    
    /// Requests the user notification permissions defined by requestedUserNotificationSettings(). Call this when the user should be prompted for user notification permissions. The first time (per installation and requestedUserNotificationSettings().types configuration) that this method is called the user will be prompted for user notification permissions. Subsequent attempts will not prompt users, but will result in didReceiveUserNotificationPermissions(_:) being called.
    final public func requestUserNotificationPermissions() {
        guard let userNotificationsCapableSelf = self as? UserNotificationCapable else {
            noteImproperAPIUsage("Attempting to requestUserNotificationPermissions when app \(self) subclass does not conform to UserNotificationCapable protocol.")
            return
        }
        
        // Note that we have registered for user notifications. Every time the the app comes to the foreground in the future (with the same requestedUserNotificationSettings()) we'll register on the application's behalf. Registering on every applicationDidEnterForeground allows the app to always know the device's current notification settings.
        previouslyRequestedUserNotificationPermissions = true
        
        UIApplication.sharedApplication().registerUserNotificationSettings(userNotificationsCapableSelf.requestedUserNotificationSettings())
    }
    
    
    // MARK: Public Properties
    
    
    /// A preference key for determining if we have previously registered for user notifications.
    /// @see previouslyRequestedUserNotificationPermissions
    private static let PreviouslyRequestedUserNotificationPermissionsPreferencesKey = "PreviouslyRequestedUserNotificationPermissions"
    public internal(set) var previouslyRequestedUserNotificationPermissions: Bool {
        get {
            guard let userNotificationsCapableSelf = self as? UserNotificationCapable else {
                noteImproperAPIUsage("Attempting to query previouslyRequestedUserNotificationPermissions when app \(self) subclass does not conform to UserNotificationCapable protocol.")
                return false
            }
            
            return NSUserDefaults.standardUserDefaults().boolForKey("\(SuperDelegate.PreviouslyRequestedUserNotificationPermissionsPreferencesKey).\(userNotificationsCapableSelf.requestedUserNotificationSettings().types)")
        }
        
        set {
            guard let userNotificationsCapableSelf = self as? UserNotificationCapable else {
                noteImproperAPIUsage("Attempting to set previouslyRequestedUserNotificationPermissions when app \(self) subclass does not conform to UserNotificationCapable protocol.")
                return
            }
            
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "\(SuperDelegate.PreviouslyRequestedUserNotificationPermissionsPreferencesKey).\(userNotificationsCapableSelf.requestedUserNotificationSettings().types)")
        }
    }
    
    
    // MARK: UIApplicationDelegate
    
    
    final public func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        guard let userNotificationsCapableSelf = self as? UserNotificationCapable else {
            noteImproperAPIUsage("Received didRegisterUserNotificationSettings but \(self) does not conform to UserNotificationCapable.")
            return
        }
        
        if let currentUserNotificationSettings = application.currentUserNotificationSettings() {
            // Some versions of iOS give us an incomplete notificationSettings options. Therefore, union the options with currentUserNotificationSettings to work around possible bugs in the operating system.
            let grantedPermissions = currentUserNotificationSettings.types.union(notificationSettings.types)
            userNotificationsCapableSelf.didReceiveUserNotificationPermissions(UserNotificationPermissionsGranted(grantedPermissions: grantedPermissions, preferredPermissions: userNotificationsCapableSelf.requestedUserNotificationSettings().types))
            
        } else {
            userNotificationsCapableSelf.didReceiveUserNotificationPermissions(UserNotificationPermissionsGranted(grantedPermissions: notificationSettings.types, preferredPermissions: userNotificationsCapableSelf.requestedUserNotificationSettings().types))
        }
    }
}
