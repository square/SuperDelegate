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
    func requestedUserNotificationSettings() -> UIUserNotificationSettings
    
    /// Called every time user notifications are registered. Will happen every time the application is brought to the foreground after requestUserNotificationPermissions is called.
    func didReceive(userNotificationPermissions: UserNotificationPermissionsGranted)
}


// MARK: - UserNotificationPermissionsGranted


public enum UserNotificationPermissionsGranted: Equatable {
    /// None of the permissions detailed in requestedUserNotificationSettings().types are granted.
    case none
    /// A partial set of the permissions detailed in requestedUserNotificationSettings().types are granted.
    case partial(grantedPermissions: UIUserNotificationType)
    /// All of the permissions detailed in requestedUserNotificationSettings().types are granted.
    case requested
    
    // MARK: Equatable
    
    public static func ==(lhs: UserNotificationPermissionsGranted, rhs: UserNotificationPermissionsGranted) -> Bool {
        switch (lhs, rhs) {
        case (.requested, .requested):
            return true
        case let (.partial(lhsGrantedPermissions), .partial(rhsGrantedPermissions)) where lhsGrantedPermissions == rhsGrantedPermissions:
            return true
        case (.none, .none):
            return true
        default:
            return false
        }
    }
    
    // MARK: Initialization
    
    internal init(grantedPermissions: UIUserNotificationType, preferredPermissions: UIUserNotificationType) {
        if grantedPermissions.rawValue & preferredPermissions.rawValue == preferredPermissions.rawValue {
            self = .requested
        } else if grantedPermissions != [] {
            self = .partial(grantedPermissions: grantedPermissions)
        } else {
            self = .none
        }
    }
}


public enum UserNotificationOrigin {
    /// The user tapped the notification to bring the app to the foreground
    case userTappedToBringAppToForeground
    /// The user has not seen the notification since it was delivered while the app was in the foreground
    case deliveredWhileInForeground
    /// The user may have seen the notification, but hasn't tapped on it. RemoteNotification
    case deliveredWhileInBackground
}


// MARK: - SuperDelegate User Notification Extension


extension SuperDelegate {
    
    
    // MARK: Public Methods
    
    
    /// Requests the user notification permissions defined by requestedUserNotificationSettings(). Call this when the user should be prompted for user notification permissions. The first time (per installation and requestedUserNotificationSettings().types configuration) that this method is called the user will be prompted for user notification permissions. Subsequent attempts will not prompt users, but will result in didReceive(userNotificationPermissions:) being called.
    final public func requestUserNotificationPermissions() {
        guard let userNotificationsCapableSelf = self as? UserNotificationCapable else {
            noteImproperAPIUsage("Attempting to requestUserNotificationPermissions when app \(self) subclass does not conform to UserNotificationCapable protocol.")
            return
        }
        
        // Note that we have registered for user notifications. Every time the the app comes to the foreground in the future (with the same requestedUserNotificationSettings()) we'll register on the application's behalf. Registering on every applicationDidEnterForeground allows the app to always know the device's current notification settings.
        previouslyRequestedUserNotificationPermissions = true
        
        UIApplication.shared.registerUserNotificationSettings(userNotificationsCapableSelf.requestedUserNotificationSettings())
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
            
            return UserDefaults.standard.bool(forKey: "\(SuperDelegate.PreviouslyRequestedUserNotificationPermissionsPreferencesKey).\(userNotificationsCapableSelf.requestedUserNotificationSettings().types)")
        }
        
        set {
            guard let userNotificationsCapableSelf = self as? UserNotificationCapable else {
                noteImproperAPIUsage("Attempting to set previouslyRequestedUserNotificationPermissions when app \(self) subclass does not conform to UserNotificationCapable protocol.")
                return
            }
            
            UserDefaults.standard.set(newValue, forKey: "\(SuperDelegate.PreviouslyRequestedUserNotificationPermissionsPreferencesKey).\(userNotificationsCapableSelf.requestedUserNotificationSettings().types)")
        }
    }
    
    
    // MARK: UIApplicationDelegate
    
    
    @objc(application:didRegisterUserNotificationSettings:)
    final public func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        guard let userNotificationsCapableSelf = self as? UserNotificationCapable else {
            noteImproperAPIUsage("Received didRegisterUserNotificationSettings but \(self) does not conform to UserNotificationCapable.")
            return
        }
        
        if let currentUserNotificationSettings = application.currentUserNotificationSettings {
            // Some versions of iOS give us an incomplete notificationSettings options. Therefore, union the options with currentUserNotificationSettings to work around possible bugs in the operating system.
            let grantedPermissions = currentUserNotificationSettings.types.union(notificationSettings.types)
            userNotificationsCapableSelf.didReceive(userNotificationPermissions: UserNotificationPermissionsGranted(grantedPermissions: grantedPermissions, preferredPermissions: userNotificationsCapableSelf.requestedUserNotificationSettings().types))
            
        } else {
            userNotificationsCapableSelf.didReceive(userNotificationPermissions: UserNotificationPermissionsGranted(grantedPermissions: notificationSettings.types, preferredPermissions: userNotificationsCapableSelf.requestedUserNotificationSettings().types))
        }
    }
}
