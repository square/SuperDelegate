//
//  RemoteNotificationTests.swift
//  SuperDelegate
//
//  Created by Dan Federman on 4/15/16.
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

import XCTest
@testable import SuperDelegate

class RemoteNotificationTests: XCTestCase {
    
    func test_RemoteNotification_initWithFullRemoteNotificationDictionary() {
        let remoteNotificationDictionary: [NSObject : AnyObject] = [
            APSServiceKey : [
                alertKey : [
                    alertBodyKey : alertBody,
                    alertBodyLocKey : alertBodyLocalizationKey,
                    alertBodyLocArgsKey : alertBodyLocalizationArgs,
                    alertActionLocKey : alertActionLocalizationKey,
                    alertLaunchImageKey : alertLaunchImageName,
                    alertWearableTitleKey : alertWearableTitle,
                    alertWearableTitleLocKey : alertWearableTitleLocalizationKey,
                    alertWearableTitleLocArgsKey : alertWearableTitleLocalizationArgs
                ],
                badgeKey : badge,
                soundKey : sound,
                contentAvailableKey : contentAvailable,
                categoryKey : categoryIdentifier,
            ],
            userInfoCustomKey1 : userInfoCustomValue1,
            userInfoCustomKey2 : userInfoCustomValue2,
            userInfoCustomKey3 : userInfoCustomValue3
        ]
        
        guard let remoteNotification = RemoteNotification(remoteNotification: remoteNotificationDictionary) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(alertBody, remoteNotification.alert?.body)
        XCTAssertEqual(alertBodyLocalizationKey, remoteNotification.alert?.bodyLocalizationKey)
        XCTAssertEqual(alertBodyLocalizationArgs.count, remoteNotification.alert?.bodyLocalizationArguments?.count)
        for alertBodyLocalizationArg in alertBodyLocalizationArgs {
            if let bodyLocalizationArguments = remoteNotification.alert?.bodyLocalizationArguments {
                XCTAssertTrue(bodyLocalizationArguments.contains(alertBodyLocalizationArg))
            } else {
                XCTFail()
            }
        }
        XCTAssertEqual(alertLaunchImageName, remoteNotification.alert?.launchImageName)
        XCTAssertEqual(alertWearableTitle, remoteNotification.alert?.wearableTitle)
        XCTAssertEqual(alertWearableTitleLocalizationKey, remoteNotification.alert?.wearableTitleLocalizationKey)
        XCTAssertEqual(alertWearableTitleLocalizationArgs.count, remoteNotification.alert?.wearableTitleLocalizationArguments?.count)
        for alertWearableTitleLocalizationArg in alertWearableTitleLocalizationArgs {
            if let wearableTitleLocalizationArguments = remoteNotification.alert?.wearableTitleLocalizationArguments {
                XCTAssertTrue(wearableTitleLocalizationArguments.contains(alertWearableTitleLocalizationArg))
            } else {
                XCTFail()
            }
        }
        XCTAssertEqual(badge, remoteNotification.badge)
        XCTAssertEqual(sound, remoteNotification.sound)
        XCTAssertTrue(remoteNotification.contentAvailable)
        XCTAssertEqual(categoryIdentifier, remoteNotification.categoryIdentifier)
        XCTAssertEqual(remoteNotification.userInfo.count, 3)
        XCTAssertEqual(remoteNotification.userInfo[userInfoCustomKey1] as? String, userInfoCustomValue1)
        XCTAssertEqual(remoteNotification.userInfo[userInfoCustomKey2] as? String, userInfoCustomValue2)
        XCTAssertEqual(remoteNotification.userInfo[userInfoCustomKey3] as? Int, userInfoCustomValue3)
        
        XCTAssertTrue(remoteNotification == RemoteNotification(remoteNotification: remoteNotificationDictionary)!)
        var differentRemoteNotificationDictionary = remoteNotificationDictionary
        differentRemoteNotificationDictionary[userInfoCustomKey3 + "many different"] = "wow"
        XCTAssertNotEqual(remoteNotification, RemoteNotification(remoteNotification: differentRemoteNotificationDictionary))
    }
    
    func test_RemoteNotification_initWithSimpleAlertRemoteNotificationDictionary() {
        let remoteNotificationDictionary: [NSObject : AnyObject] = [
            APSServiceKey : [
                alertKey : alertBody,
                badgeKey : badge,
                soundKey : sound,
                contentAvailableKey : contentAvailable,
                categoryKey : categoryIdentifier,
            ],
            userInfoCustomKey1 : userInfoCustomValue1,
            userInfoCustomKey2 : userInfoCustomValue2,
            userInfoCustomKey3 : userInfoCustomValue3
        ]
        
        guard let remoteNotification = RemoteNotification(remoteNotification: remoteNotificationDictionary) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(alertBody, remoteNotification.alert?.body)
        XCTAssertEqual(nil, remoteNotification.alert?.bodyLocalizationKey)
        XCTAssertEqual(nil, remoteNotification.alert?.bodyLocalizationArguments?.first)
        XCTAssertEqual(nil, remoteNotification.alert?.launchImageName)
        XCTAssertEqual(nil, remoteNotification.alert?.wearableTitle)
        XCTAssertEqual(nil, remoteNotification.alert?.wearableTitleLocalizationKey)
        XCTAssertEqual(nil, remoteNotification.alert?.wearableTitleLocalizationArguments?.first)
        
        XCTAssertEqual(badge, remoteNotification.badge)
        XCTAssertEqual(sound, remoteNotification.sound)
        XCTAssertTrue(remoteNotification.contentAvailable)
        XCTAssertEqual(categoryIdentifier, remoteNotification.categoryIdentifier)
        XCTAssertEqual(remoteNotification.userInfo.count, 3)
        XCTAssertEqual(remoteNotification.userInfo[userInfoCustomKey1] as? String, userInfoCustomValue1)
        XCTAssertEqual(remoteNotification.userInfo[userInfoCustomKey2] as? String, userInfoCustomValue2)
        XCTAssertEqual(remoteNotification.userInfo[userInfoCustomKey3] as? Int, userInfoCustomValue3)
        
        XCTAssertTrue(remoteNotification == RemoteNotification(remoteNotification: remoteNotificationDictionary)!)
        var differentRemoteNotificationDictionary = remoteNotificationDictionary
        differentRemoteNotificationDictionary[userInfoCustomKey3 + "many different"] = "wow"
        XCTAssertNotEqual(remoteNotification, RemoteNotification(remoteNotification: differentRemoteNotificationDictionary))
    }
    
    func test_RemoteNotification_initWithSilentRemoteNotificationDictionary() {
        let remoteNotificationDictionary: [NSObject : AnyObject] = [
            APSServiceKey : [
                badgeKey : badge,
                soundKey : sound,
                contentAvailableKey : contentAvailable,
                categoryKey : categoryIdentifier,
            ],
            userInfoCustomKey1 : userInfoCustomValue1,
            userInfoCustomKey2 : userInfoCustomValue2,
            userInfoCustomKey3 : userInfoCustomValue3
        ]
        
        guard let remoteNotification = RemoteNotification(remoteNotification: remoteNotificationDictionary) else {
            XCTFail()
            return
        }
        
        XCTAssertNil(remoteNotification.alert?.body)
        XCTAssertNil(remoteNotification.alert?.bodyLocalizationKey)
        XCTAssertNil(remoteNotification.alert?.bodyLocalizationArguments?.count)
        XCTAssertNil(remoteNotification.alert?.launchImageName)
        XCTAssertNil(remoteNotification.alert?.wearableTitle)
        XCTAssertNil(remoteNotification.alert?.wearableTitleLocalizationKey)
        XCTAssertNil(remoteNotification.alert?.wearableTitleLocalizationArguments?.count)
        
        XCTAssertEqual(badge, remoteNotification.badge)
        XCTAssertEqual(sound, remoteNotification.sound)
        XCTAssertTrue(remoteNotification.contentAvailable)
        XCTAssertEqual(categoryIdentifier, remoteNotification.categoryIdentifier)
        XCTAssertEqual(remoteNotification.userInfo.count, 3)
        XCTAssertEqual(remoteNotification.userInfo[userInfoCustomKey1] as? String, userInfoCustomValue1)
        XCTAssertEqual(remoteNotification.userInfo[userInfoCustomKey2] as? String, userInfoCustomValue2)
        XCTAssertEqual(remoteNotification.userInfo[userInfoCustomKey3] as? Int, userInfoCustomValue3)
        
        XCTAssertTrue(remoteNotification == RemoteNotification(remoteNotification: remoteNotificationDictionary)!)
        let differentRemoteNotificationDictionary: [NSObject : AnyObject] = [
            APSServiceKey : [
                badgeKey : badge,
                soundKey : sound,
                contentAvailableKey : contentAvailable,
                // Note that categoryKey is missing.
            ],
            userInfoCustomKey1 : userInfoCustomValue1,
            userInfoCustomKey2 : userInfoCustomValue2,
            userInfoCustomKey3 : userInfoCustomValue3
        ]

        XCTAssertNotEqual(remoteNotification, RemoteNotification(remoteNotification: differentRemoteNotificationDictionary))
    }
    
    func test_RemoteNotification_initWithBadgeChangeRemoteNotificationDictionary() {
        let remoteNotificationDictionary: [NSObject : AnyObject] = [
            APSServiceKey : [
                badgeKey : badge,
                soundKey : sound,
            ],
        ]
        
        guard let remoteNotification = RemoteNotification(remoteNotification: remoteNotificationDictionary) else {
            XCTFail()
            return
        }
        
        XCTAssertNil(remoteNotification.alert?.body)
        XCTAssertNil(remoteNotification.alert?.bodyLocalizationKey)
        XCTAssertNil(remoteNotification.alert?.bodyLocalizationArguments?.count)
        XCTAssertNil(remoteNotification.alert?.launchImageName)
        XCTAssertNil(remoteNotification.alert?.wearableTitle)
        XCTAssertNil(remoteNotification.alert?.wearableTitleLocalizationKey)
        XCTAssertNil(remoteNotification.alert?.wearableTitleLocalizationArguments?.count)

        XCTAssertEqual(badge, remoteNotification.badge)
        XCTAssertEqual(sound, remoteNotification.sound)
        XCTAssertFalse(remoteNotification.contentAvailable)
        
        XCTAssertNil(remoteNotification.categoryIdentifier)
        XCTAssertEqual(remoteNotification.userInfo.count, 0)
        
        XCTAssertTrue(remoteNotification == RemoteNotification(remoteNotification: remoteNotificationDictionary)!)
        var differentRemoteNotificationDictionary = remoteNotificationDictionary
        differentRemoteNotificationDictionary[badgeKey] = badge+1
        XCTAssertNotEqual(remoteNotification, RemoteNotification(remoteNotification: differentRemoteNotificationDictionary))
    }

}


// MARK: - APNS Dictionary Values


let alertBody = "This is an alert body"
let alertBodyLocalizationKey = "a loc key"
let alertBodyLocalizationArgs = ["argument"]
let alertActionLocalizationKey = "another loc key"
let alertLaunchImageName = "imageName"
let alertWearableTitle = "Alert!"
let alertWearableTitleLocalizationKey = "loc key 3"
let alertWearableTitleLocalizationArgs = ["many argument", "such localization", "wow"]

let badge = 2
let sound = "beLoud.mp3"
let contentAvailable = 1
let categoryIdentifier = "doTheThings"
let userInfoCustomKey1 = "a custom key"
let userInfoCustomValue1 = "a custom value"
let userInfoCustomKey2 = "another custom key"
let userInfoCustomValue2 = "another custom value"
let userInfoCustomKey3 = "3rd custom key"
let userInfoCustomValue3 = 3
