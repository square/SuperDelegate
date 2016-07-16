//
//  RemoteNotification.swift
//  SuperDelegate
//
//  Created by Dan Federman on 4/14/16.
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


public struct RemoteNotification: CustomStringConvertible, Equatable {
    /// An object representing the user-facing alert. Derived from userInfo["aps"]["alert"]
    public let alert: Alert?
    /// The badge set on the remote notification. Derived from userInfo["badge"]
    public let badge: Int?
    /// The sound that the notification plays. Derived from userInfo["sound"]
    public let sound: String?
    /// Whether the push indicates that content is available for download. Derived from userInfo["content-available"]
    public let contentAvailable: Bool
    /// The identifier for the UIUserNotificationCategory associated with the push notification. Derived from userInfo["category"]
    public let categoryIdentifier: String?
    /// Custom fields on the remote notification.
    public let userInfo: [String : AnyObject]
    /// The dictionary representation of the remote notification.
    public let remoteNotificationDictionary: [String : AnyObject]
    
    public init?(remoteNotification: [NSObject : AnyObject]?) {
        guard let remoteNotification = remoteNotification as? [String : AnyObject] else {
            return nil
        }
        
        // Parse the notification payload.
        // See https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/TheNotificationPayload.html for more information on expected values.
        alert = Alert(remoteNotification: remoteNotification)
        
        let apnsDictionary = remoteNotification[APSServiceKey] as? [String : AnyObject]
        badge = apnsDictionary?[badgeKey] as? Int
        sound = apnsDictionary?[soundKey] as? String
        contentAvailable = apnsDictionary?[contentAvailableKey] != nil
        categoryIdentifier = apnsDictionary?[categoryKey] as? String
        remoteNotificationDictionary = remoteNotification
        
        var customFields = remoteNotification
        customFields.removeValueForKey(APSServiceKey)
        
        userInfo = customFields
    }
    
    // MARK: CustomStringConvertible
    
    public var description: String {
        return remoteNotificationDictionary.description
    }
    
    // MARK: Alert
    
    public struct Alert: Equatable {
        /// The alert message text. Derived from userInfo["aps"]["alert"]["body"] or userInfo["aps"]["alert"]
        public let body: String?
        /// The localization key for the alert message text. Derived from userInfo["aps"]["alert"]["loc-key"]
        public let bodyLocalizationKey: String?
        /// The localization arguments for the alert message text. Derived from userInfo["aps"]["alert"]["loc-args"]
        public let bodyLocalizationArguments: [String]?
        
        /// The localization key for the alert action button. Derived from userInfo["aps"]["alert"]["action-loc-key"]
        public let actionLocalizationKey: String?
        
        /// The filename of an image file in the app bundle, with or without the filename extension. Derived from userInfo["aps"]["alert"]["launch-image"]
        public let launchImageName: String?
        
        /// The title shown on the Apple Watch. Derived from userInfo["aps"]["alert"]["title"]
        public let wearableTitle: String?
        /// The localization key for the title shown on the Apple Watch. Derived from userInfo["aps"]["alert"]["title-loc-key"]
        public let wearableTitleLocalizationKey: String?
        /// The localization arguments for the title shown on the Apple Watch. Derived from userInfo["aps"]["alert"]["title-loc-args"]
        public let wearableTitleLocalizationArguments: [String]?
        
        init?(remoteNotification: [String : AnyObject]) {
            // Alert is represented as either a dictionary or a single string.
            guard let alert = remoteNotification[APSServiceKey]?[alertKey] as? [String : AnyObject] else {
                guard let body = remoteNotification[APSServiceKey]?[alertKey] as? String else {
                    return nil
                }
                
                self.body = body
                
                bodyLocalizationKey = nil
                bodyLocalizationArguments = nil
                actionLocalizationKey = nil
                launchImageName = nil
                wearableTitle = nil
                wearableTitleLocalizationKey = nil
                wearableTitleLocalizationArguments = nil

                return
            }
            
            body = alert[alertBodyKey] as? String
            bodyLocalizationKey = alert[alertBodyLocKey] as? String
            bodyLocalizationArguments = alert[alertBodyLocArgsKey] as? [String]
            
            actionLocalizationKey = alert[alertActionLocKey] as? String
            
            launchImageName = alert[alertLaunchImageKey] as? String
            
            wearableTitle = alert[alertWearableTitleKey] as? String
            wearableTitleLocalizationKey = alert[alertWearableTitleLocKey] as? String
            wearableTitleLocalizationArguments = alert[alertWearableTitleLocArgsKey] as? [String]
        }
    }
}


// MARK: Equatable

@warn_unused_result
public func ==(lhs: RemoteNotification, rhs: RemoteNotification) -> Bool {
    if lhs.alert != nil || rhs.alert != nil {
        guard let lhsAlert = lhs.alert, let rhsAlert = rhs.alert where lhsAlert == rhsAlert else {
            return false
        }
    }
    
    if lhs.badge != nil || rhs.badge != nil {
        guard let lhsBadge = lhs.badge, let rhsBadge = rhs.badge where lhsBadge == rhsBadge else {
            return false
        }
    }
    
    if lhs.sound != nil || rhs.sound != nil {
        guard let lhsSound = lhs.sound, let rhsSound = rhs.sound where lhsSound == rhsSound else {
            return false
        }
    }
    
    guard lhs.contentAvailable == rhs.contentAvailable else {
        return false
    }
    
    if lhs.categoryIdentifier != nil || rhs.categoryIdentifier != nil {
        guard let lhsCategoryIdentifier = lhs.categoryIdentifier, let rhsCategoryIdentifier = rhs.categoryIdentifier where lhsCategoryIdentifier == rhsCategoryIdentifier else {
            return false
        }
    }

    guard NSDictionary(dictionary: lhs.userInfo) == NSDictionary(dictionary: rhs.userInfo) else {
        return false
    }
    
    return true
}

@warn_unused_result
public func ==(lhs: RemoteNotification.Alert, rhs: RemoteNotification.Alert) -> Bool {
    if lhs.body != nil || rhs.body != nil {
        guard let lhsBody = lhs.body, let rhsBody = rhs.body where lhsBody == rhsBody else {
            return false
        }
    }
    
    if lhs.bodyLocalizationKey != nil || rhs.bodyLocalizationKey != nil {
        guard let lhsBodyLocalizationKey = lhs.bodyLocalizationKey, let rhsBodyLocalizationKey = rhs.bodyLocalizationKey where lhsBodyLocalizationKey == rhsBodyLocalizationKey else {
            return false
        }
    }
    
    if lhs.bodyLocalizationArguments != nil || rhs.bodyLocalizationArguments != nil {
        guard let lhsBodyLocalizationArguments = lhs.bodyLocalizationArguments, let rhsBodyLocalizationArguments = rhs.bodyLocalizationArguments where lhsBodyLocalizationArguments == rhsBodyLocalizationArguments else {
            return false
        }
    }

    if lhs.actionLocalizationKey != nil || rhs.actionLocalizationKey != nil {
        guard let lhsActionLocalizationKey = lhs.actionLocalizationKey, let rhsActionLocalizationKey = rhs.actionLocalizationKey where lhsActionLocalizationKey == rhsActionLocalizationKey else {
            return false
        }
    }
    
    if lhs.launchImageName != nil || rhs.launchImageName != nil {
        guard let lhsLaunchImageName = lhs.launchImageName, let rhsLaunchImageName = rhs.launchImageName where lhsLaunchImageName == rhsLaunchImageName else {
            return false
        }
    }
    
    if lhs.wearableTitle != nil || rhs.wearableTitle != nil {
        guard let lhsWearableTitle = lhs.wearableTitle, let rhsWearableTitle = rhs.wearableTitle where lhsWearableTitle == rhsWearableTitle else {
            return false
        }
    }
    
    if lhs.wearableTitleLocalizationKey != nil || rhs.wearableTitleLocalizationKey != nil {
        guard let lhsWearableTitleLocalizationKey = lhs.wearableTitleLocalizationKey, let rhsWearableTitleLocalizationKey = rhs.wearableTitleLocalizationKey where lhsWearableTitleLocalizationKey == rhsWearableTitleLocalizationKey else {
            return false
        }
    }
    
    if lhs.wearableTitleLocalizationArguments != nil || rhs.wearableTitleLocalizationArguments != nil {
        guard let lhsWearableTitleLocalizationArguments = lhs.wearableTitleLocalizationArguments, let rhsWearableTitleLocalizationArguments = rhs.wearableTitleLocalizationArguments where lhsWearableTitleLocalizationArguments == rhsWearableTitleLocalizationArguments else {
            return false
        }
    }
    
    return true
}


// MARK: Top Level APS Keys


let APSServiceKey = "aps"


// MARK: APS Keys


let alertKey = "alert"
let badgeKey = "badge"
let soundKey = "sound"
let contentAvailableKey = "content-available"
let categoryKey = "category"


// MARK: Alert Keys


let alertBodyKey = "body"
let alertBodyLocKey = "loc-key"
let alertBodyLocArgsKey = "loc-args"
let alertActionLocKey = "action-loc-key"
let alertLaunchImageKey = "launch-image"
let alertWearableTitleKey = "title"
let alertWearableTitleLocKey = "title-loc-key"
let alertWearableTitleLocArgsKey = "title-loc-args"
