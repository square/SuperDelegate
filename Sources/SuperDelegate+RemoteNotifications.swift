//
//  SuperDelegate+RemoteNotifications.swift
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


// MARK: RemoteNotificationCapable – Opting into this protocol gives your app the ability to receive remote notifications.


public protocol RemoteNotificationCapable: ApplicationLaunched {
    /// Called whenever the app successfully registers for remote notifications. This method may be called many times during a single application launch. Use this method to hand your server your notification token.
    func didRegisterForRemoteNotificationsWithToken(deviceToken: NSData)
    
    /// Called when your app fails to register for remote notifications. There is no recovery mechanism once registration fails. In practice this method should almost never be called. Log the error or present it to the user.
    func didFailToRegisterForRemoteNotificationsWithError(error: NSError)
    
    /// Called when your app receives a remote notification. Will not be called for notifications that were delivered to the app via loadInterfaceWithLaunchItem(_:).
    func didReceiveRemoteNotification(remoteNotification: RemoteNotification, notificationOrigin: UserNotificationOrigin, fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void))
}


// MARK: - RemoteNotificationActionCapable – Opting into this protocol gives your app the ability to handle actions on remote notifications.


public protocol RemoteNotificationActionCapable: RemoteNotificationCapable, UserNotificationCapable {
    /// Called when your app has to handle a remote notification action tapped by the user. Execute completionHandler when your application has handled the action to prevent iOS from killing your app.
    func handleRemoteNotificationActionWithIdentifier(actionIdentifier: String?, forRemoteNotification notification: RemoteNotification, withResponseInfo responseInfo: [String : AnyObject]?, completionHandler: () -> Void)
}


// MARK: - SuperDelegate Remote Notification Extension


public extension SuperDelegate {
    
    
    // MARK: UIApplicationDelegate
    
    
    final public func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        guard let remoteNotificationsCapableSelf = self as? RemoteNotificationCapable else {
            noteImproperAPIUsage("SuperDelegate registered for remote notifications but \(self) does not conform to RemoteNotificationCapable. Ignoring.")
            return
        }
        
        remoteNotificationsCapableSelf.didRegisterForRemoteNotificationsWithToken(deviceToken)
    }
    
    final public func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        guard let remoteNotificationsCapableSelf = self as? RemoteNotificationCapable else {
            noteImproperAPIUsage("SuperDelegate did fail to register for remote notifications but \(self) does not conform to RemoteNotificationCapable. Ignoring.")
            return
        }
        
        remoteNotificationsCapableSelf.didFailToRegisterForRemoteNotificationsWithError(error)
    }
    
    final public func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        guard let remoteNotificationsCapableSelf = self as? RemoteNotificationCapable else {
            noteImproperAPIUsage("Received remote notification but \(self) does not conform to RemoteNotificationCapable. Ignoring.")
            completionHandler(.NoData)
            return
        }
        
        guard let remoteNotification = RemoteNotification(remoteNotification: userInfo) else {
            // Bail out. We don't have a remote notification we understand.
            noteImproperAPIUsage("SuperDelegate could not parse remote notification \(userInfo)\nIgnoring")
            completionHandler(.NoData)
            return
        }
        
        guard launchOptionsRemoteNotification != remoteNotification else {
            // Bail out. We've already processed this notification.
            completionHandler(.NoData)
            return
        }
        
        let notificationOrigin: UserNotificationOrigin
        if applicationIsInForeground {
            notificationOrigin = .DeliveredWhileInForground
        } else if application.applicationState == .Background && remoteNotification.contentAvailable {
            notificationOrigin = .DeliveredWhileInBackground
        } else {
            notificationOrigin = .UserTappedToBringAppToForeground
        }
        
        remoteNotificationsCapableSelf.didReceiveRemoteNotification(remoteNotification,
                                                                    notificationOrigin: notificationOrigin,
                                                                    fetchCompletionHandler: completionHandler)
    }
    
    final public func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        // This method may be called if the application hasn't added "remote-notification" to the UIBackgroundModes array in Info.plist.
        self.application(application, didReceiveRemoteNotification: userInfo) { (_) in
            // Nothing to do here.
        }
    }
    
    final public func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        guard let remoteNotificationActionCapableSelf = self as? RemoteNotificationActionCapable else {
            noteImproperAPIUsage("Received local notification action but \(self) does not conform to RemoteNotificationActionCapable. Ignoring.")
            completionHandler()
            return
        }
        
        guard let remoteNotification = RemoteNotification(remoteNotification: userInfo) else {
            // Bail out. We don't have a remote notification we understand.
            noteImproperAPIUsage("SuperDelegate could not parse remote notification \(userInfo)\nIgnoring")
            completionHandler()
            return
        }
        
        remoteNotificationActionCapableSelf.handleRemoteNotificationActionWithIdentifier(identifier, forRemoteNotification: remoteNotification, withResponseInfo: nil, completionHandler: completionHandler)
    }
    
    final public func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        guard let remoteNotificationActionCapableSelf = self as? RemoteNotificationActionCapable else {
            noteImproperAPIUsage("Received local notification action but \(self) does not conform to RemoteNotificationActionCapable. Ignoring.")
            completionHandler()
            return
        }
        
        guard let remoteNotification = RemoteNotification(remoteNotification: userInfo) else {
            // Bail out. We don't have a remote notification we understand.
            noteImproperAPIUsage("SuperDelegate could not parse remote notification \(userInfo)\nIgnoring")
            completionHandler()
            return
        }
        
        remoteNotificationActionCapableSelf.handleRemoteNotificationActionWithIdentifier(identifier, forRemoteNotification: remoteNotification, withResponseInfo: responseInfo as? [String : AnyObject], completionHandler: completionHandler)
    }
    
}
