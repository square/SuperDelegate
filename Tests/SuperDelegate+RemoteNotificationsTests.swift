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
        let deviceToken = "a token".data(using: String.Encoding.utf8)!
        remoteNotificationCapableDelegate.application(UIApplication.shared, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        XCTAssertEqual(deviceToken, remoteNotificationCapableDelegate.registeredDeviceToken)
    }
    
    func test_didFailToRegisterForRemoteNotificationsWithError_forwardsError() {
        let remoteNotificationCapableDelegate = RemoteNotificationCapableDelegate()
        let registrationError = NSError(domain: "push registration test", code: 0, userInfo: nil)
        remoteNotificationCapableDelegate.application(UIApplication.shared, didFailToRegisterForRemoteNotificationsWithError: registrationError)
        if let registeredFailure = remoteNotificationCapableDelegate.registerFailure as? NSError {
            XCTAssertEqual(registrationError, registeredFailure)
            
        } else {
            XCTFail()
        }
    }
    
    func test_didFinishLaunchingWithOptions_loadsInterfaceWithRemoteNotification() {
        let remoteNotificationCapableDelegate = RemoteNotificationCapableDelegate()
        let remoteNotificationDictionary: [AnyHashable : Any] = [
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
        let remoteNotification = RemoteNotification(remoteNotification: remoteNotificationDictionary)!
        
        XCTAssertTrue(
            remoteNotificationCapableDelegate.application(UIApplication.shared,
                                                          didFinishLaunchingWithOptions: [
                                                            UIApplicationLaunchOptionsKey.remoteNotification : remoteNotificationDictionary
                ]
            )
        )
        
        switch remoteNotificationCapableDelegate.launchItem {
        case let .remoteNotification(launchRemoteNotification):
            XCTAssertEqual(launchRemoteNotification, remoteNotification)
        default:
            XCTFail()
        }
    }
    
    func test_didReceiveRemoteNotification_deliversRemoteNotificationWithProperOrigin() {
        let remoteNotificationCapableDelegate = RemoteNotificationCapableDelegate()
        let remoteNotificationDictionary: [AnyHashable : Any] = [
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
        let remoteNotification = RemoteNotification(remoteNotification: remoteNotificationDictionary)!
        
        remoteNotificationCapableDelegate.loadInterfaceOnce(with: .none)
        
        var fetchCompletionHandlerExecuted = false
        remoteNotificationCapableDelegate.application(UIApplication.shared, didReceiveRemoteNotification: remoteNotificationDictionary) { (_) in
            fetchCompletionHandlerExecuted = true
        }
        
        XCTAssertTrue(fetchCompletionHandlerExecuted)
        
        XCTAssertEqual(remoteNotificationCapableDelegate.receivedRemoteNotification, remoteNotification)
        XCTAssertEqual(remoteNotificationCapableDelegate.receivedNotificationOrigin, UserNotificationOrigin.userTappedToBringAppToForeground)
        
        remoteNotificationCapableDelegate.applicationIsInForeground = true
        
        fetchCompletionHandlerExecuted = false
        remoteNotificationCapableDelegate.application(UIApplication.shared, didReceiveRemoteNotification: remoteNotificationDictionary) { (_) in
            fetchCompletionHandlerExecuted = true
        }
        
        XCTAssertTrue(fetchCompletionHandlerExecuted)
        
        XCTAssertEqual(remoteNotificationCapableDelegate.receivedRemoteNotification, remoteNotification)
        XCTAssertEqual(remoteNotificationCapableDelegate.receivedNotificationOrigin, UserNotificationOrigin.deliveredWhileInForeground)
    }
    
    func test_didReceiveRemoteNotification_dropsRemoteNotificationDeliveredToLoadInterfaceWithLaunchItem() {
        let remoteNotificationCapableDelegate = RemoteNotificationCapableDelegate()
        let remoteNotificationDictionary: [AnyHashable : Any] = [
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
        let remoteNotification = RemoteNotification(remoteNotification: remoteNotificationDictionary)!
        
        XCTAssertTrue(
            remoteNotificationCapableDelegate.application(UIApplication.shared,
                                                          didFinishLaunchingWithOptions: [
                                                            UIApplicationLaunchOptionsKey.remoteNotification : remoteNotificationDictionary
                ]
            )
        )
        
        switch remoteNotificationCapableDelegate.launchItem {
        case let .remoteNotification(launchRemoteNotification):
            XCTAssertEqual(launchRemoteNotification, remoteNotification)
        default:
            XCTFail()
        }
        
        XCTAssertNil(remoteNotificationCapableDelegate.receivedRemoteNotification)
        
        remoteNotificationCapableDelegate.application(UIApplication.shared, didReceiveRemoteNotification: remoteNotificationDictionary, fetchCompletionHandler: { (_) in
            // Nothing to do here.
        })
        
        XCTAssertNil(remoteNotificationCapableDelegate.receivedRemoteNotification)
    }
    
    func test_didReceiveRemoteNotification_doesNotDropRemoteNotificationDeliveredToLoadInterfaceWithLaunchItemAfterApplicationWillEnterForeground() {
        let remoteNotificationCapableDelegate = RemoteNotificationCapableDelegate()
        let remoteNotificationDictionary: [AnyHashable : Any] = [
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
        let remoteNotification = RemoteNotification(remoteNotification: remoteNotificationDictionary)!
        
        XCTAssertTrue(
            remoteNotificationCapableDelegate.application(UIApplication.shared,
                                                          didFinishLaunchingWithOptions: [
                                                            UIApplicationLaunchOptionsKey.remoteNotification : remoteNotificationDictionary
                ]
            )
        )
        
        switch remoteNotificationCapableDelegate.launchItem {
        case let .remoteNotification(launchRemoteNotification):
            XCTAssertEqual(launchRemoteNotification, remoteNotification)
        default:
            XCTFail()
        }
        
        XCTAssertNil(remoteNotificationCapableDelegate.receivedRemoteNotification)
        
        NotificationCenter.default.post(name: NSNotification.Name.UIApplicationWillEnterForeground, object: UIApplication.shared)
        
        remoteNotificationCapableDelegate.application(UIApplication.shared, didReceiveRemoteNotification: remoteNotificationDictionary, fetchCompletionHandler: { (_) in
            // Nothing to do here.
        })
        
        XCTAssertEqual(remoteNotificationCapableDelegate.receivedRemoteNotification, remoteNotification)
    }
    
    func test_didReceiveRemoteNotification_doesNotDropRemoteNotificationDifferentThanRemoteNotificationDeliveredToLoadInterfaceWithLaunchItem() {
        let remoteNotificationCapableDelegate = RemoteNotificationCapableDelegate()
        let remoteNotificationDictionary: [AnyHashable : Any] = [
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
        let remoteNotification = RemoteNotification(remoteNotification: remoteNotificationDictionary)!
        
        XCTAssertTrue(
            remoteNotificationCapableDelegate.application(UIApplication.shared,
                                                          didFinishLaunchingWithOptions: [
                                                            UIApplicationLaunchOptionsKey.remoteNotification : remoteNotificationDictionary
                ]
            )
        )
        
        switch remoteNotificationCapableDelegate.launchItem {
        case let .remoteNotification(launchRemoteNotification):
            XCTAssertEqual(launchRemoteNotification, remoteNotification)
        default:
            XCTFail()
        }
        
        XCTAssertNil(remoteNotificationCapableDelegate.receivedRemoteNotification)
        
        let otherRemoteNotificationDictionary: [AnyHashable : Any] = [
            alertKey : [
                alertBodyKey : "other " + alertBody,
                alertBodyLocKey : "other" + alertBodyLocalizationKey,
            ]
        ]
        let otherRemoteNotification = RemoteNotification(remoteNotification: otherRemoteNotificationDictionary)!
        
        remoteNotificationCapableDelegate.application(UIApplication.shared, didReceiveRemoteNotification: otherRemoteNotificationDictionary, fetchCompletionHandler: { (_) in
            // Nothing to do here.
        })
        
        XCTAssertEqual(remoteNotificationCapableDelegate.receivedRemoteNotification, otherRemoteNotification)
    }
    
    
    // MARK: RemoteNotificationActionCapableDelegate Tests
    
    
    func test_receivingRemoteNotificationAction_notifies() {
        let remoteNotificationActionCapableDelegate = RemoteNotificationActionCapableDelegate()
        let remoteNotificationDictionary: [AnyHashable : Any] = [
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
        let remoteNotification = RemoteNotification(remoteNotification: remoteNotificationDictionary)!
        let actionIdentifier = "some action"
        
        var completionHandlerExecuted = false
        remoteNotificationActionCapableDelegate.application(UIApplication.shared, handleActionWithIdentifier: actionIdentifier, forRemoteNotification: remoteNotificationDictionary) {
            completionHandlerExecuted = true
        }
        
        XCTAssertTrue(completionHandlerExecuted)
        XCTAssertEqual(remoteNotification, remoteNotificationActionCapableDelegate.handledRemoteNotification)
        XCTAssertEqual(actionIdentifier, remoteNotificationActionCapableDelegate.handledActionIdentifier)
        XCTAssertNil(remoteNotificationActionCapableDelegate.handledResponseInfo)
    }
    
    func test_receivingLocalNotificationWithResponseInfoAction_notifies() {
        let remoteNotificationActionCapableDelegate = RemoteNotificationActionCapableDelegate()
        let remoteNotificationDictionary: [AnyHashable : Any] = [
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
        let remoteNotification = RemoteNotification(remoteNotification: remoteNotificationDictionary)!
        let actionIdentifier = "some action"
        let responseInfo = ["a response" : "object"]
        
        var completionHandlerExecuted = false
        remoteNotificationActionCapableDelegate.application(UIApplication.shared, handleActionWithIdentifier: actionIdentifier, forRemoteNotification: remoteNotificationDictionary, withResponseInfo: responseInfo) {
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
    
    var registeredDeviceToken: Data?
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        registeredDeviceToken = deviceToken
    }
    
    var registerFailure: Error?
    func didFailToRegisterForRemoteNotifications(withError error: Error) {
        registerFailure = error
    }
    
    var receivedRemoteNotification: RemoteNotification?
    var receivedNotificationOrigin: UserNotificationOrigin?
    func didReceive(remoteNotification: RemoteNotification, origin: UserNotificationOrigin, fetchCompletionHandler completionHandler: @escaping ((UIBackgroundFetchResult) -> Swift.Void)) {
        receivedRemoteNotification = remoteNotification
        receivedNotificationOrigin = origin
        completionHandler(.noData)
    }
}


// MARK: - RemoteNotificationActionCapableDelegate


class RemoteNotificationActionCapableDelegate: RemoteNotificationCapableDelegate, RemoteNotificationActionCapable {
    
    func requestedUserNotificationSettings() -> UIUserNotificationSettings {
        return UIUserNotificationSettings()
    }
    
    func didReceive(userNotificationPermissions: UserNotificationPermissionsGranted) {
        
    }
    
    var handledActionIdentifier: String? = ""
    var handledRemoteNotification = RemoteNotification(remoteNotification: [AnyHashable : Any]())
    var handledResponseInfo: [String : Any]? = nil
    func handleRemoteNotificationAction(withActionIdentifier actionIdentifier: String?, forRemoteNotification notification: RemoteNotification, withResponseInfo responseInfo: [String : Any]?, completionHandler: @escaping () -> Swift.Void) {
        handledActionIdentifier = actionIdentifier
        handledRemoteNotification = notification
        handledResponseInfo = responseInfo
        completionHandler()
    }
}
