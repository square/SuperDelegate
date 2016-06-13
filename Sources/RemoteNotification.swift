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
    public let userInfo: [String : Any]
    /// The dictionary representation of the remote notification.
    public let remoteNotificationDictionary: [String : Any]
    
    // MARK: Equatable
    
    public static func ==(lhs: RemoteNotification, rhs: RemoteNotification) -> Bool {
        return lhs.alert == rhs.alert
            && lhs.badge == rhs.badge
            && lhs.sound == rhs.sound
            && lhs.contentAvailable == rhs.contentAvailable
            && lhs.categoryIdentifier == rhs.categoryIdentifier
            && NSDictionary(dictionary: lhs.userInfo) == NSDictionary(dictionary: rhs.userInfo)
    }
    
    public init?(remoteNotification: [AnyHashable : Any]?) {
        guard let remoteNotification = remoteNotification as? [String : Any] else {
            return nil
        }
        
        // Parse the notification payload.
        // See https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/TheNotificationPayload.html for more information on expected values.
        alert = Alert(remoteNotification: remoteNotification)
        
        let apnsDictionary = remoteNotification[APSServiceKey] as? [String : Any]
        badge = apnsDictionary?[badgeKey] as? Int
        sound = apnsDictionary?[soundKey] as? String
        contentAvailable = apnsDictionary?[contentAvailableKey] != nil
        categoryIdentifier = apnsDictionary?[categoryKey] as? String
        remoteNotificationDictionary = remoteNotification
        
        var customFields = remoteNotification
        customFields.removeValue(forKey: APSServiceKey)
        
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
        
        // MARK: Equatable
        
        public static func ==(lhs: Alert, rhs: Alert) -> Bool {
            return lhs.body == rhs.body
                && lhs.bodyLocalizationKey == rhs.bodyLocalizationKey
                && lhs.bodyLocalizationArguments ?? [] == rhs.bodyLocalizationArguments ?? []
                && lhs.actionLocalizationKey == rhs.actionLocalizationKey
                && lhs.launchImageName == rhs.launchImageName
                && lhs.wearableTitle == rhs.wearableTitle
                && lhs.wearableTitleLocalizationKey == rhs.wearableTitleLocalizationKey
                && lhs.wearableTitleLocalizationArguments ?? [] == rhs.wearableTitleLocalizationArguments ?? []
        }
        
        init?(remoteNotification: [String : Any]) {
            // Alert is represented as either a dictionary or a single string.
            guard let apnsDictionary = remoteNotification[APSServiceKey] as? [String : Any] else {
                return nil
            }
            
            guard let alert = apnsDictionary[alertKey] as? [String : Any] else {
                guard let body = apnsDictionary[alertKey] as? String else {
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
