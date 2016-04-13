//
//  SuperDelegate+RemoteNotificationsTests.swift
//  SuperDelegate
//
//  Created by Dan Federman on 4/18/16.
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


class SuperDelegateRemoteNotificationTests: SuperDelegateTests {
    
    
    // MARK: - Behavioral Tests
    
    
    // MARK: RemoteNotificationCapableDelegate Tests
    
    
    func test_registerForRemoteNotificationsWithDeviceToken_forwardsToken() {
        let remoteNotificationCapableDelegate = RemoteNotificationCapableDelegate()
        let deviceToken = "a token".dataUsingEncoding(NSUTF8StringEncoding)!
        remoteNotificationCapableDelegate.application(UIApplication.sharedApplication(), didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        XCTAssertEqual(deviceToken, remoteNotificationCapableDelegate.registeredDeviceToken)
    }
    
    func test_didFailToRegisterForRemoteNotificationsWithError_forwardsError() {
        let remoteNotificationCapableDelegate = RemoteNotificationCapableDelegate()
        let registrationError = NSError(domain: "push registration test", code: 0, userInfo: nil)
        remoteNotificationCapableDelegate.application(UIApplication.sharedApplication(), didFailToRegisterForRemoteNotificationsWithError: registrationError)
        XCTAssertEqual(registrationError, remoteNotificationCapableDelegate.registerFailure)
    }
    
    func test_didFinishLaunchingWithOptions_loadsInterfaceWithRemoteNotification() {
        let remoteNotificationCapableDelegate = RemoteNotificationCapableDelegate()
        let remoteNotificationDictionary: [NSObject : AnyObject] = [
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
            userInfoCustomKey1 : userInfoCustomValue1,
            userInfoCustomKey2 : userInfoCustomValue2,
            userInfoCustomKey3 : userInfoCustomValue3
        ]
        let remoteNotification = RemoteNotification(remoteNotification: remoteNotificationDictionary)!
        
        XCTAssertTrue(
            remoteNotificationCapableDelegate.application(UIApplication.sharedApplication(),
                didFinishLaunchingWithOptions: [
                    UIApplicationLaunchOptionsRemoteNotificationKey : remoteNotificationDictionary
                ]
            )
        )
        
        switch remoteNotificationCapableDelegate.launchItem {
        case let .RemoteNotificationItem(launchRemoteNotification):
            XCTAssertEqual(launchRemoteNotification, remoteNotification)
        default:
            XCTFail()
        }
    }
    
    func test_didReceiveRemoteNotification_deliversRemoteNotificationWithProperOrigin() {
        let remoteNotificationCapableDelegate = RemoteNotificationCapableDelegate()
        let remoteNotificationDictionary: [NSObject : AnyObject] = [
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
            userInfoCustomKey1 : userInfoCustomValue1,
            userInfoCustomKey2 : userInfoCustomValue2,
            userInfoCustomKey3 : userInfoCustomValue3
        ]
        let remoteNotification = RemoteNotification(remoteNotification: remoteNotificationDictionary)!
        
        remoteNotificationCapableDelegate.loadInterfaceOnceWithLaunchItem(.NoItem)
        
        var fetchCompletionHandlerExecuted = false
        remoteNotificationCapableDelegate.application(UIApplication.sharedApplication(), didReceiveRemoteNotification: remoteNotificationDictionary) { (_) in
            fetchCompletionHandlerExecuted = true
        }
        
        XCTAssertTrue(fetchCompletionHandlerExecuted)
        
        XCTAssertEqual(remoteNotificationCapableDelegate.receivedRemoteNotification, remoteNotification)
        XCTAssertEqual(remoteNotificationCapableDelegate.receivedNotificationOrigin, UserNotificationOrigin.UserTappedToBringAppToForeground)
        
        remoteNotificationCapableDelegate.applicationIsInForeground = true
        
        fetchCompletionHandlerExecuted = false
        remoteNotificationCapableDelegate.application(UIApplication.sharedApplication(), didReceiveRemoteNotification: remoteNotificationDictionary) { (_) in
            fetchCompletionHandlerExecuted = true
        }
        
        XCTAssertTrue(fetchCompletionHandlerExecuted)
        
        XCTAssertEqual(remoteNotificationCapableDelegate.receivedRemoteNotification, remoteNotification)
        XCTAssertEqual(remoteNotificationCapableDelegate.receivedNotificationOrigin, UserNotificationOrigin.DeliveredWhileInForground)
    }
    
    func test_didReceiveRemoteNotification_dropsRemoteNotificationDeliveredToLoadInterfaceWithLaunchItem() {
        let remoteNotificationCapableDelegate = RemoteNotificationCapableDelegate()
        let remoteNotificationDictionary: [NSObject : AnyObject] = [
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
            userInfoCustomKey1 : userInfoCustomValue1,
            userInfoCustomKey2 : userInfoCustomValue2,
            userInfoCustomKey3 : userInfoCustomValue3
        ]
        let remoteNotification = RemoteNotification(remoteNotification: remoteNotificationDictionary)!
        
        XCTAssertTrue(
            remoteNotificationCapableDelegate.application(UIApplication.sharedApplication(),
                didFinishLaunchingWithOptions: [
                    UIApplicationLaunchOptionsRemoteNotificationKey : remoteNotificationDictionary
                ]
            )
        )
        
        switch remoteNotificationCapableDelegate.launchItem {
        case let .RemoteNotificationItem(launchRemoteNotification):
            XCTAssertEqual(launchRemoteNotification, remoteNotification)
        default:
            XCTFail()
        }
        
        XCTAssertNil(remoteNotificationCapableDelegate.receivedRemoteNotification)
        
        remoteNotificationCapableDelegate.application(UIApplication.sharedApplication(), didReceiveRemoteNotification: remoteNotificationDictionary, fetchCompletionHandler: { (_) in
            // Nothing to do here.
        })
        
        XCTAssertNil(remoteNotificationCapableDelegate.receivedRemoteNotification)
    }
    
    func test_didReceiveRemoteNotification_doesNotDropRemoteNotificationDeliveredToLoadInterfaceWithLaunchItemAfterApplicationWillEnterForeground() {
        let remoteNotificationCapableDelegate = RemoteNotificationCapableDelegate()
        let remoteNotificationDictionary: [NSObject : AnyObject] = [
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
            userInfoCustomKey1 : userInfoCustomValue1,
            userInfoCustomKey2 : userInfoCustomValue2,
            userInfoCustomKey3 : userInfoCustomValue3
        ]
        let remoteNotification = RemoteNotification(remoteNotification: remoteNotificationDictionary)!
        
        XCTAssertTrue(
            remoteNotificationCapableDelegate.application(UIApplication.sharedApplication(),
                didFinishLaunchingWithOptions: [
                    UIApplicationLaunchOptionsRemoteNotificationKey : remoteNotificationDictionary
                ]
            )
        )
        
        switch remoteNotificationCapableDelegate.launchItem {
        case let .RemoteNotificationItem(launchRemoteNotification):
            XCTAssertEqual(launchRemoteNotification, remoteNotification)
        default:
            XCTFail()
        }
        
        XCTAssertNil(remoteNotificationCapableDelegate.receivedRemoteNotification)
        
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication())
        
        remoteNotificationCapableDelegate.application(UIApplication.sharedApplication(), didReceiveRemoteNotification: remoteNotificationDictionary, fetchCompletionHandler: { (_) in
            // Nothing to do here.
        })
        
        XCTAssertEqual(remoteNotificationCapableDelegate.receivedRemoteNotification, remoteNotification)
    }
    
    func test_didReceiveRemoteNotification_doesNotDropRemoteNotificationDifferentThanRemoteNotificationDeliveredToLoadInterfaceWithLaunchItem() {
        let remoteNotificationCapableDelegate = RemoteNotificationCapableDelegate()
        let remoteNotificationDictionary: [NSObject : AnyObject] = [
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
            userInfoCustomKey1 : userInfoCustomValue1,
            userInfoCustomKey2 : userInfoCustomValue2,
            userInfoCustomKey3 : userInfoCustomValue3
        ]
        let remoteNotification = RemoteNotification(remoteNotification: remoteNotificationDictionary)!
        
        XCTAssertTrue(
            remoteNotificationCapableDelegate.application(UIApplication.sharedApplication(),
                didFinishLaunchingWithOptions: [
                    UIApplicationLaunchOptionsRemoteNotificationKey : remoteNotificationDictionary
                ]
            )
        )
        
        switch remoteNotificationCapableDelegate.launchItem {
        case let .RemoteNotificationItem(launchRemoteNotification):
            XCTAssertEqual(launchRemoteNotification, remoteNotification)
        default:
            XCTFail()
        }
        
        XCTAssertNil(remoteNotificationCapableDelegate.receivedRemoteNotification)
        
        let otherRemoteNotificationDictionary: [NSObject : AnyObject] = [
            alertKey : [
                alertBodyKey : "other " + alertBody,
                alertBodyLocKey : "other" + alertBodyLocalizationKey,
            ]
        ]
        let otherRemoteNotification = RemoteNotification(remoteNotification: otherRemoteNotificationDictionary)!

        remoteNotificationCapableDelegate.application(UIApplication.sharedApplication(), didReceiveRemoteNotification: otherRemoteNotificationDictionary, fetchCompletionHandler: { (_) in
            // Nothing to do here.
        })
        
        XCTAssertEqual(remoteNotificationCapableDelegate.receivedRemoteNotification, otherRemoteNotification)
    }
    
    
    // MARK: RemoteNotificationActionCapableDelegate Tests
    
    
    func test_receivingRemoteNotificationAction_notifies() {
        let remoteNotificationActionCapableDelegate = RemoteNotificationActionCapableDelegate()
        let remoteNotificationDictionary: [NSObject : AnyObject] = [
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
            userInfoCustomKey1 : userInfoCustomValue1,
            userInfoCustomKey2 : userInfoCustomValue2,
            userInfoCustomKey3 : userInfoCustomValue3
        ]
        let remoteNotification = RemoteNotification(remoteNotification: remoteNotificationDictionary)!
        let actionIdentifier = "some action"
        
        var completionHandlerExecuted = false
        remoteNotificationActionCapableDelegate.application(UIApplication.sharedApplication(), handleActionWithIdentifier: actionIdentifier, forRemoteNotification: remoteNotificationDictionary) {
            completionHandlerExecuted = true
        }
        
        XCTAssertTrue(completionHandlerExecuted)
        XCTAssertEqual(remoteNotification, remoteNotificationActionCapableDelegate.handledRemoteNotification)
        XCTAssertEqual(actionIdentifier, remoteNotificationActionCapableDelegate.handledActionIdentifier)
        XCTAssertNil(remoteNotificationActionCapableDelegate.handledResponseInfo)
    }
    
    func test_receivingLocalNotificationWithResponseInfoAction_notifies() {
        let remoteNotificationActionCapableDelegate = RemoteNotificationActionCapableDelegate()
        let remoteNotificationDictionary: [NSObject : AnyObject] = [
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
            userInfoCustomKey1 : userInfoCustomValue1,
            userInfoCustomKey2 : userInfoCustomValue2,
            userInfoCustomKey3 : userInfoCustomValue3
        ]
        let remoteNotification = RemoteNotification(remoteNotification: remoteNotificationDictionary)!
        let actionIdentifier = "some action"
        let responseInfo = ["a response" : "object"]
        
        var completionHandlerExecuted = false
        remoteNotificationActionCapableDelegate.application(UIApplication.sharedApplication(), handleActionWithIdentifier: actionIdentifier, forRemoteNotification: remoteNotificationDictionary, withResponseInfo: responseInfo) {
            completionHandlerExecuted = true
        }
        
        XCTAssertTrue(completionHandlerExecuted)
        XCTAssertEqual(remoteNotification, remoteNotificationActionCapableDelegate.handledRemoteNotification)
        XCTAssertEqual(actionIdentifier, remoteNotificationActionCapableDelegate.handledActionIdentifier)
        XCTAssertEqual(responseInfo, remoteNotificationActionCapableDelegate.handledResponseInfo as! [String : String])
    }
}


// MARK: - RemoteNotificationCapableDelegate


class RemoteNotificationCapableDelegate: AppLaunchedDelegate, RemoteNotificationCapable {
    
    var registeredDeviceToken: NSData?
    func didRegisterForRemoteNotificationsWithToken(deviceToken: NSData) {
        registeredDeviceToken = deviceToken
    }
    
    var registerFailure: NSError?
    func didFailToRegisterForRemoteNotificationsWithError(error: NSError) {
        registerFailure = error
    }
    
    var receivedRemoteNotification: RemoteNotification?
    var receivedNotificationOrigin: UserNotificationOrigin?
    func didReceiveRemoteNotification(remoteNotification: RemoteNotification, notificationOrigin: UserNotificationOrigin, fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)) {
        receivedRemoteNotification = remoteNotification
        receivedNotificationOrigin = notificationOrigin
        completionHandler(.NoData)
    }
}


// MARK: - RemoteNotificationActionCapableDelegate


class RemoteNotificationActionCapableDelegate: RemoteNotificationCapableDelegate, RemoteNotificationActionCapable {
    
    func requestedUserNotificationSettings() -> UIUserNotificationSettings {
        return UIUserNotificationSettings()
    }
    
    func didReceiveUserNotificationPermissions(userNotificationPermissionsGranted: UserNotificationPermissionsGranted) {
        
    }
    
    var handledActionIdentifier: String? = ""
    var handledRemoteNotification = RemoteNotification(remoteNotification: [NSObject : AnyObject]())
    var handledResponseInfo: [String : AnyObject]? = nil
    func handleRemoteNotificationActionWithIdentifier(actionIdentifier: String?, forRemoteNotification notification: RemoteNotification, withResponseInfo responseInfo: [String : AnyObject]?, completionHandler: () -> Void) {
        handledActionIdentifier = actionIdentifier
        handledRemoteNotification = notification
        handledResponseInfo = responseInfo
        completionHandler()
    }
}
