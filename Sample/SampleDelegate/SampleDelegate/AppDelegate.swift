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
    
    var window: UIWindow?
    
    // MARK: ApplicationLaunched
    
    func setupApplication() {
        // Setup app model, networking, logging, etc.
    }
    
    func loadInterface(launchItem: LaunchItem) {
        // Setup our main window since we don't have a storyboard.
        let window = UIWindow()
        self.window = window
        setup(mainWindow: window)
        window.rootViewController = ViewController()
        
        switch launchItem {
        case let .remoteNotification(item):
            // Show UI for the remote notification that brought us into the foreground.
            didReceive(remoteNotification: item, origin: .userTappedToBringAppToForeground, fetchCompletionHandler: { (_) in
                // Nothing to do here.
            })
            
        case let .localNotification(item):
            // Show UI for the local notification that brought us into the foreground.
            didReceive(localNotification: item, origin: .userTappedToBringAppToForeground)
            
        case let .openURL(item):
            // If we have a urlToOpen launch item, SuperDelegate has guaranteed that we can open that URL.
            let _ = handle(urlToOpen: item)
            
        case let .shortcut(item):
            // Process the shortcut item.
            handle(shortcutItem: item, completionHandler: {
                // Nothing to do here.
            })
            
        case let .userActivity(item):
            // If we have a userActivity launch item, SuperDelegate has guaranteed that we can continue this user activity.
            let _ = resume(userActivity: item, restorationHandler: { (_) in
                // Nothing to do here.
            })
            
        case .sourceApplication:
            break // Nothing to do here.
            
        case .none:
            // We were launched because the launched us from Springboard or the App Switcher.
            break
        }
    }
}

extension AppDelegate: RemoteNotificationCapable {
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        // Update server with the new token.
    }
    
    func didFailToRegisterForRemoteNotifications(withError error: Error) {
        // Tell the server that push can't succeed right now.
    }
    
    func didReceive(remoteNotification: RemoteNotification, origin: UserNotificationOrigin, fetchCompletionHandler completionHandler: (@escaping (UIBackgroundFetchResult) -> Void)) {
        switch origin {
        case .userTappedToBringAppToForeground:
            // The customer tapped on the notification. Show UI about the notification.
            break
            
        case .deliveredWhileInForeground:
            // The customer has not seen this notification. Alert the customer somehow.
            break
            
        case .deliveredWhileInBackground:
            // Process the background notification.
            break
        }
    }
}

extension AppDelegate: UserNotificationCapable {
    func requestedUserNotificationSettings() -> UIUserNotificationSettings {
        return UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
    }
    
    func didReceive(userNotificationPermissions: UserNotificationPermissionsGranted) {
        switch userNotificationPermissions {
        case .none:
            // The customer has denied user (e.g. local and loud remote) notification permissions.
            break
        case .requested:
            // The customer has given us permission for all requested user notifications.
            break
        case let .partial(grantedPermissions):
            print("Customer refused to give us permissions for \(requestedUserNotificationSettings().types.symmetricDifference(grantedPermissions))")
            break
        }
    }
}

extension AppDelegate: LocalNotificationCapable {
    func didReceive(localNotification: UILocalNotification, origin: UserNotificationOrigin) {
        // Process the notification.
    }
}

extension AppDelegate: OpenURLCapable {
    func canOpen(launchURL: URLToOpen) -> Bool {
        // SampleDelegate can handle all URLs given to us at launch! If some URLs shouldn't open your app, return false here.
        return true
    }
    
    func handle(urlToOpen: URLToOpen) -> Bool {
        // Show UI that corresponds to the opened URL. If you can't open the URL, return false here.
        return true
    }
}

extension AppDelegate: ShortcutCapable {
    func canHandle(shortcutItem: UIApplicationShortcutItem) -> Bool {
        // SampleDelegate can handle all shortcut items! If your app needs to invalidate shortcut items that were set by a previous version of the app, return false here.
        return true
    }
    
    func handle(shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping () -> Void) {
        // Process the shortcut, then tell iOS that we've handled the shortcut.
        completionHandler()
    }
}

extension AppDelegate: UserActivityCapable {
    func canResume(userActivity: NSUserActivity) -> Bool {
        // SampleDelegate can handle all user activity items!
        return true
    }
    
    func resume(userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        // Show UI for the user activity.
        return true
    }
}
