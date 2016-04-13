//
//  AppDelegate.swift
//  SampleDelegate
//
//  Created by Dan Federman on 6/11/16.
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

import UIKit
import SuperDelegate


@UIApplicationMain
class AppDelegate: SuperDelegate, ApplicationLaunched {

    let window = UIWindow()
    
    // MARK: ApplicationLaunched
    
    func setupApplication() {
        // Setup app model, networking, logging, etc.
    }
    
    func loadInterfaceWithLaunchItem(launchItem: LaunchItem) {
        // Setup our main window since we don't have a storyboard.
        setupMainWindow(window)
        window.rootViewController = ViewController()
        
        switch launchItem {
        case let .RemoteNotificationItem(remoteNotification):
            // Show UI for the remote notification that brought us into the foreground.
            didReceiveRemoteNotification(remoteNotification, notificationOrigin: .UserTappedToBringAppToForeground, fetchCompletionHandler: { (_) in
                // Nothing to do here.
            })
            
        case let .LocalNotificationItem(localNotification):
            // Show UI for the local notification that brought us into the foreground.
            didReceiveLocalNotification(localNotification, notificationOrigin: .UserTappedToBringAppToForeground)
            
        case let .OpenURLItem(urlToOpen):
            // If we have a urlToOpen launch item, SuperDelegate has guaranteed that we can open that URL.
            handleURLToOpen(urlToOpen)
            
        case let .ShortcutItem(shortcutItem):
            // Process the shortcut item.
            handleShortcutItem(shortcutItem, completionHandler: {
                // Nothing to do here.
            })
            
        case let .UserActivityItem(userActivity):
            // If we have a userActivity launch item, SuperDelegate has guaranteed that we can continue this user activity.
            continueUserActivity(userActivity, restorationHandler: { (_) in
                // Nothing to do here.
            })
            
        case .NoItem:
            // We were launched because the launched us from Springboard or the App Switcher.
            break
        }
    }
}

extension AppDelegate: RemoteNotificationCapable {
    func didRegisterForRemoteNotificationsWithToken(deviceToken: NSData) {
        // Update server with the new token.
    }
    
    func didFailToRegisterForRemoteNotificationsWithError(error: NSError) {
        // Tell the server that push can't succeed right now.
    }
    
    func didReceiveRemoteNotification(remoteNotification: RemoteNotification, notificationOrigin: UserNotificationOrigin, fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)) {
        switch notificationOrigin {
        case .UserTappedToBringAppToForeground:
            // The customer tapped on the notification. Show UI about the notification.
            break
            
        case .DeliveredWhileInForground:
            // The customer has not seen this notification. Alert the customer somehow.
            break
            
        case .DeliveredWhileInBackground:
            // Process the background notification.
            break
        }
    }
}

extension AppDelegate: UserNotificationCapable {
    func requestedUserNotificationSettings() -> UIUserNotificationSettings {
        return UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
    }
    
    func didReceiveUserNotificationPermissions(userNotificationPermissionsGranted: UserNotificationPermissionsGranted) {
        switch userNotificationPermissionsGranted {
        case .None:
            // The customer has denied user (e.g. local and loud remote) notification permissions.
            break
        case .Requested:
            // The customer has given us permission for all requested user notifications.
            break
        case let .Some(grantedPermissions):
            print("Customer refused to give us permissions for \(requestedUserNotificationSettings().types.exclusiveOr(grantedPermissions))")
            break
        }
    }
}

extension AppDelegate: LocalNotificationCapable {
    func didReceiveLocalNotification(localNotification: UILocalNotification, notificationOrigin: UserNotificationOrigin) {
        // Process the notification.
    }
}

extension AppDelegate: OpenURLCapable {
    func canOpenLaunchURL(launchURLToOpen: URLToOpen) -> Bool {
        // SampleDelegate can handle all URLs given to us at launch! If some URLs shouldn't open your app, return false here.
        return true
    }
    
    func handleURLToOpen(urlToOpen: URLToOpen) -> Bool {
        // Show UI that corresponds to the opened URL. If you can't open the URL, return false here.
        return true
    }
}

extension AppDelegate: ShortcutCapable {
    func canHandleShortcutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        // SampleDelegate can handle all shortcut items! If your app needs to invalidate shortcut items that were set by a previous version of the app, return false here.
        return true
    }
    
    func handleShortcutItem(shortcutItem: UIApplicationShortcutItem, completionHandler: () -> Void) {
        // Process the shortcut, then tell iOS that we've handled the shortcut.
        completionHandler()
    }
}

extension AppDelegate: UserActivityCapable {
    func canHandleUserActivity(userActivity: NSUserActivity) -> Bool {
        // SampleDelegate can handle all user activity items!
        return true
    }
    
    func continueUserActivity(userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        // Show UI for the user activity.
        return true
    }
}