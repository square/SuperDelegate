//
//  SuperDelegate+LocalNotifications.swift
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


// MARK: LocalNotificationCapable – Opting into this protocol gives your app the ability to process local notifications.


public protocol LocalNotificationCapable: UserNotificationCapable {
    /// Called when your app receives a local notification. Will not be called for notifications that were delivered to the app via loadInterfaceWithLaunchItem(_:).
    func didReceiveLocalNotification(localNotification: UILocalNotification, notificationOrigin: UserNotificationOrigin)
}


// MARK: - LocalNotificationActionCapable – Opting into this protocol gives your app the ability to handle actions on local notifications.


public protocol LocalNotificationActionCapable: LocalNotificationCapable {
    /// Called when your app has to handle a local notification action tapped by the user. Execute completionHandler when your application has handled the action to prevent iOS from killing your app.
    func handleLocalNotificationActionWithIdentifier(actionIdentifier: String?, forLocalNotification notification: UILocalNotification, withResponseInfo responseInfo: [String : AnyObject]?, completionHandler: () -> Void)
}


// MARK: - SuperDelegate Local Notification Extension


extension SuperDelegate {
    
    
    // MARK: UIApplicationDelegate
    
    
    final public func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        guard let localNotificationsCapableSelf = self as? LocalNotificationCapable else {
            noteImproperAPIUsage("Received local notification but \(self) does not conform to LocalNotificationCapable. Ignoring.")
            return
        }
        
        guard launchOptionsLocalNotification !== notification else {
            // Bail out. We've already processed this notification.
            return
        }
        
        let notificationOrigin: UserNotificationOrigin
        if applicationIsInForeground {
            notificationOrigin = .DeliveredWhileInForground
        } else {
            notificationOrigin = .UserTappedToBringAppToForeground
        }
        
        localNotificationsCapableSelf.didReceiveLocalNotification(notification, notificationOrigin: notificationOrigin)
    }
    
    final public func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        guard let localNotificationActionCapableSelf = self as? LocalNotificationActionCapable else {
            noteImproperAPIUsage("Received local notification action but \(self) does not conform to LocalNotificationActionCapable. Ignoring.")
            completionHandler()
            return
        }
        
        localNotificationActionCapableSelf.handleLocalNotificationActionWithIdentifier(identifier, forLocalNotification: notification, withResponseInfo: nil, completionHandler: completionHandler)
    }
    
    final public func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        guard let localNotificationActionCapableSelf = self as? LocalNotificationActionCapable else {
            noteImproperAPIUsage("Received local notification action but \(self) does not conform to LocalNotificationActionCapable. Ignoring.")
            completionHandler()
            return
        }
        
        localNotificationActionCapableSelf.handleLocalNotificationActionWithIdentifier(identifier, forLocalNotification: notification, withResponseInfo: responseInfo as? [String : AnyObject], completionHandler: completionHandler)
    }
}
