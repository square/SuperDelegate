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
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data)
    
    /// Called when your app fails to register for remote notifications. There is no recovery mechanism once registration fails. In practice this method should almost never be called. Log the error or present it to the user.
    func didFailToRegisterForRemoteNotifications(withError error: Error)
    
    /// Called when your app receives a remote notification. Will not be called for notifications that were delivered to the app via loadInterface(launchItem:).
    func didReceive(remoteNotification: RemoteNotification, origin: UserNotificationOrigin, fetchCompletionHandler completionHandler: @escaping ((UIBackgroundFetchResult) -> Swift.Void))
}


// MARK: - RemoteNotificationActionCapable – Opting into this protocol gives your app the ability to handle actions on remote notifications.


public protocol RemoteNotificationActionCapable: RemoteNotificationCapable, UserNotificationCapable {
    /// Called when your app has to handle a remote notification action tapped by the user. Execute completionHandler when your application has handled the action to prevent iOS from killing your app.
    func handleRemoteNotificationAction(withActionIdentifier actionIdentifier: String?, forRemoteNotification notification: RemoteNotification, withResponseInfo responseInfo: [String : Any]?, completionHandler: @escaping () -> Swift.Void)
}


// MARK: - SuperDelegate Remote Notification Extension


public extension SuperDelegate {
    
    
    // MARK: UIApplicationDelegate
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard let remoteNotificationsCapableSelf = self as? RemoteNotificationCapable else {
            noteImproperAPIUsage("SuperDelegate registered for remote notifications but \(self) does not conform to RemoteNotificationCapable. Ignoring.")
            return
        }
        
        remoteNotificationsCapableSelf.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    final public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        guard let remoteNotificationsCapableSelf = self as? RemoteNotificationCapable else {
            noteImproperAPIUsage("SuperDelegate did fail to register for remote notifications but \(self) does not conform to RemoteNotificationCapable. Ignoring.")
            return
        }
        
        remoteNotificationsCapableSelf.didFailToRegisterForRemoteNotifications(withError: error)
    }
    
    final public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {
        guard let remoteNotificationsCapableSelf = self as? RemoteNotificationCapable else {
            noteImproperAPIUsage("Received remote notification but \(self) does not conform to RemoteNotificationCapable. Ignoring.")
            completionHandler(.noData)
            return
        }
        
        guard let remoteNotification = RemoteNotification(remoteNotification: userInfo) else {
            // Bail out. We don't have a remote notification we understand.
            noteImproperAPIUsage("SuperDelegate could not parse remote notification \(userInfo)\nIgnoring")
            completionHandler(.noData)
            return
        }
        
        guard launchOptionsRemoteNotification != remoteNotification else {
            // Bail out. We've already processed this notification.
            completionHandler(.noData)
            return
        }
        
        let notificationOrigin: UserNotificationOrigin
        if applicationIsInForeground {
            notificationOrigin = .deliveredWhileInForeground
        } else if application.applicationState == .background && remoteNotification.contentAvailable {
            notificationOrigin = .deliveredWhileInBackground
        } else {
            notificationOrigin = .userTappedToBringAppToForeground
        }
        
        remoteNotificationsCapableSelf.didReceive(remoteNotification: remoteNotification,
                                                  origin: notificationOrigin,
                                                  fetchCompletionHandler: completionHandler)
    }
    
    final public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        // This method may be called if the application hasn't added "remote-notification" to the UIBackgroundModes array in Info.plist.
        self.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: { (_) in
            // Nothing to do here.
        })
    }
    
    final public func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Swift.Void) {
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
        
        remoteNotificationActionCapableSelf.handleRemoteNotificationAction(withActionIdentifier: identifier, forRemoteNotification: remoteNotification, withResponseInfo: nil, completionHandler: completionHandler)
    }
    
    final public func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Swift.Void) {
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
        
        remoteNotificationActionCapableSelf.handleRemoteNotificationAction(withActionIdentifier: identifier, forRemoteNotification: remoteNotification, withResponseInfo: (responseInfo as! [String : Any]), completionHandler: completionHandler)
    }
    
}
