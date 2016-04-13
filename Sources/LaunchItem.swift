//
//  LaunchItem.swift
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


public enum LaunchItem: CustomStringConvertible, Equatable {
    case RemoteNotificationItem(remoteNotification: RemoteNotification)
    case LocalNotificationItem(localNotification: UILocalNotification)
    case OpenURLItem(urlToOpen: URLToOpen)
    @available(iOS 9.0, *)
    case ShortcutItem(shortcutItem: UIApplicationShortcutItem)
    case UserActivityItem(userActivity: NSUserActivity)
    case NoItem
    
    // MARK: Initialization
    
    init(launchOptions: [NSObject : AnyObject]?) {
        if let launchRemoteNotification = RemoteNotification(remoteNotification: launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject]) {
            self = .RemoteNotificationItem(remoteNotification: launchRemoteNotification)
        } else if let launchLocalNotification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
            self = .LocalNotificationItem(localNotification: launchLocalNotification)
        } else if let launchURL = launchOptions?[UIApplicationLaunchOptionsURLKey] as? NSURL {
            let sourceApplicationBundleID = launchOptions?[UIApplicationLaunchOptionsSourceApplicationKey] as? String
            let annotation = launchOptions?[UIApplicationLaunchOptionsAnnotationKey]
            if #available(iOS 9.0, *) {
                self = OpenURLItem(urlToOpen: URLToOpen(
                    url: launchURL,
                    sourceApplicationBundleID: sourceApplicationBundleID,
                    annotation: annotation,
                    copyBeforeUse: launchOptions?[UIApplicationOpenURLOptionsOpenInPlaceKey] as? Bool ?? false
                    )
                )
            } else {
                self = OpenURLItem(urlToOpen: URLToOpen(
                    url: launchURL,
                    sourceApplicationBundleID: sourceApplicationBundleID,
                    annotation: annotation,
                    copyBeforeUse: false
                    )
                )
            }
        } else if #available(iOS 9.0, *), let launchShortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            self = .ShortcutItem(shortcutItem: launchShortcutItem)
        } else if let launchUserActivity = (launchOptions?[UIApplicationLaunchOptionsUserActivityDictionaryKey] as? [String : AnyObject])?[ApplicationLaunchOptionsUserActivityKey] as? NSUserActivity {
            // Unfortunately, "UIApplicationLaunchOptionsUserActivityKey" has no constant, but it is there.
            self = .UserActivityItem(userActivity: launchUserActivity)
        } else {
            self = .NoItem
        }
    }
    
    // MARK: CustomStringConvertible
    
    public var description: String {
        // Creating a custom string for LaunchItem to prevent a crash when printing any enum values with associated items on iOS 8. Swift accesses the class of every possible associated object when printing an enum instance with an asssociated value, no matter which case the instance represents. This causes a crash on iOS 8 since swift attempts to access UIApplicationShortcutItem, which doesn't exist on iOS 8. Filed rdar://26699861 – hoping for a fix in Swift 3.
        switch self {
        case let .RemoteNotificationItem(remoteNotification):
            return "LaunchItem.RemoteNotificationItem: \(remoteNotification)"
        case let .LocalNotificationItem(localNotification):
            return "LaunchItem.LocalNotificationItem: \(localNotification)"
        case let .OpenURLItem(urlToOpen):
            return "LaunchItem.OpenURLItem: \(urlToOpen)"
        case let .ShortcutItem(shortcutItem):
            return "LaunchItem.ShortcutItem: \(shortcutItem)"
        case let .UserActivityItem(userActivity):
            return "LaunchItem.UserActivityItem: \(userActivity)"
        case .NoItem:
            return "LaunchItem.NoItem"
        }
    }
    
    // MARK: Public Properties
    
    /// The launch options that were used to construct the enum, for passing into third party APIs.
    public var launchOptions: [NSObject : AnyObject] {
        get {
            switch self {
            case let .RemoteNotificationItem(remoteNotification):
                return [
                    UIApplicationLaunchOptionsRemoteNotificationKey  : remoteNotification.remoteNotificationDictionary
                ]
                
            case let .LocalNotificationItem(localNotification):
                return [
                    UIApplicationLaunchOptionsLocalNotificationKey : localNotification
                ]
                
            case let OpenURLItem(urlToOpen):
                var launchOptions: [NSObject : AnyObject] = [
                    UIApplicationLaunchOptionsURLKey : urlToOpen.url
                ]
                
                if let sourceApplicationBundleID = urlToOpen.sourceApplicationBundleID {
                    launchOptions[UIApplicationLaunchOptionsSourceApplicationKey] = sourceApplicationBundleID
                }
                
                if let annotation = urlToOpen.annotation {
                    launchOptions[UIApplicationLaunchOptionsAnnotationKey] = annotation
                }
                
                if #available(iOS 9.0, *) {
                    launchOptions[UIApplicationOpenURLOptionsOpenInPlaceKey] = urlToOpen.copyBeforeUse
                }
                
                return launchOptions
                
            case let ShortcutItem(shortcutItem):
                if #available(iOS 9.0, *) {
                    return [
                        UIApplicationLaunchOptionsShortcutItemKey : shortcutItem
                    ]
                } else {
                    // If we are a .ShortcutItem and we are not on iOS 9 or later, something absolutely terrible has happened.
                    fatalError()
                }
                
            case let UserActivityItem(userActivity):
                return [
                    UIApplicationLaunchOptionsUserActivityDictionaryKey : [
                        UIApplicationLaunchOptionsUserActivityTypeKey : userActivity.activityType,
                        ApplicationLaunchOptionsUserActivityKey : userActivity
                    ]
                ]
                
            case NoItem:
                return [:]
            }
        }
    }
}


// MARK: Equatable


@warn_unused_result
public func ==(lhs: LaunchItem, rhs: LaunchItem) -> Bool {
    switch (lhs, rhs) {
    case let (.RemoteNotificationItem(remoteNotifLHS), .RemoteNotificationItem(remoteNotifRHS)) where remoteNotifLHS == remoteNotifRHS:
        return true
    case let (.LocalNotificationItem(localNotifLHS), .LocalNotificationItem(localNotifRHS)) where localNotifLHS == localNotifRHS:
        return true
    case let (.OpenURLItem(urlLHS), .OpenURLItem(urlRHS)) where urlLHS == urlRHS:
        return true
    case let (.ShortcutItem(shortcutItemLHS), .ShortcutItem(shortcutItemRHS)) where shortcutItemLHS == shortcutItemRHS:
        return true
    case let (.UserActivityItem(userActivityTypeLHS), .UserActivityItem(userActivityTypeRHS)) where userActivityTypeLHS == userActivityTypeRHS:
        return true
    case (.NoItem, .NoItem):
        return true
    default:
        return false
    }
}
