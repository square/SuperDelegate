//
//  SuperDelegate+UserNotificationsTests.swift
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


class SuperDelegateUserNotificationTests: SuperDelegateTests {
    
    
    // MARK: - Behavioral Tests
    
    
    func test_requestUserNotificationPermissions_isNotCalledOnWillEnterForegroundIfNotPreviouslyCalled() {
        let userNotificationsCapableDelegate = UserNotificationsCapableDelegate()
        XCTAssertTrue(userNotificationsCapableDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: nil))
        XCTAssertTrue(userNotificationsCapableDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: nil))
        XCTAssertEqual(userNotificationsCapableDelegate.requestedUserNotificationSettingsCallCount, 1)
        
        NotificationCenter.default.post(name: NSNotification.Name.UIApplicationWillEnterForeground, object: UIApplication.shared)
        // One call for testing if we've previously registered.
        XCTAssertEqual(userNotificationsCapableDelegate.requestedUserNotificationSettingsCallCount, 2)
        
        userNotificationsCapableDelegate.testing_resetAllData()
    }
    
    func test_requestUserNotificationPermissions_isCalledOnWillEnterForegroundIfPreviouslyCalled() {
        let userNotificationsCapableDelegate = UserNotificationsCapableDelegate()
        XCTAssertTrue(userNotificationsCapableDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: nil))
        XCTAssertTrue(userNotificationsCapableDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: nil))
        // One call on willFinishLaunching is expected.
        XCTAssertEqual(userNotificationsCapableDelegate.requestedUserNotificationSettingsCallCount, 1)
        
        userNotificationsCapableDelegate.requestUserNotificationPermissions()
        // One call for registering, one call for noting that we registered.
        XCTAssertEqual(userNotificationsCapableDelegate.requestedUserNotificationSettingsCallCount, 3)
        
        NotificationCenter.default.post(name: NSNotification.Name.UIApplicationWillEnterForeground, object: UIApplication.shared)
        // One call for testing if we've previously registered, one call for registering, one call for setting that we have registered.
        XCTAssertEqual(userNotificationsCapableDelegate.requestedUserNotificationSettingsCallCount, 6)
        
        userNotificationsCapableDelegate.testing_resetAllData()
    }
    
    func test_requestUserNotificationPermissions_isNotCalledOnWillEnterForegroundIfPreviouslyCalledWithDifferentNotificationTypes() {
        let userNotificationsCapableDelegate = UserNotificationsCapableDelegate()
        XCTAssertTrue(userNotificationsCapableDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: nil))
        XCTAssertTrue(userNotificationsCapableDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: nil))
        XCTAssertEqual(userNotificationsCapableDelegate.requestedUserNotificationSettingsCallCount, 1)
        
        userNotificationsCapableDelegate.requestUserNotificationPermissions()
        // One call for registering, one call for noting that we registered.
        XCTAssertEqual(userNotificationsCapableDelegate.requestedUserNotificationSettingsCallCount, 3)
        
        NotificationCenter.default.post(name: NSNotification.Name.UIApplicationWillEnterForeground, object: UIApplication.shared)
        // One call for testing if we've previously registered, one call for registering, one call for setting that we have registered.
        XCTAssertEqual(userNotificationsCapableDelegate.requestedUserNotificationSettingsCallCount, 6)
        
        // A new instance should be able to read from the same pref and register (or not) accordingly.
        let userNotificationsCapableDelegateWithDifferentUserNotificationPreferences = UserNotificationsCapableDelegate()
        userNotificationsCapableDelegateWithDifferentUserNotificationPreferences.userNotificationSettingsToPrefer = UIUserNotificationSettings(types: UIUserNotificationType.alert, categories: nil)
        
        XCTAssertTrue(userNotificationsCapableDelegateWithDifferentUserNotificationPreferences.application(UIApplication.shared, willFinishLaunchingWithOptions: nil))
        XCTAssertEqual(userNotificationsCapableDelegateWithDifferentUserNotificationPreferences.requestedUserNotificationSettingsCallCount, 1)
        
        NotificationCenter.default.post(name: NSNotification.Name.UIApplicationWillEnterForeground, object: UIApplication.shared)
        // One call for testing if we've previously registered, but none for registering.
        XCTAssertEqual(userNotificationsCapableDelegateWithDifferentUserNotificationPreferences.requestedUserNotificationSettingsCallCount, 1)
        
        userNotificationsCapableDelegate.testing_resetAllData()
        userNotificationsCapableDelegateWithDifferentUserNotificationPreferences.testing_resetAllData()
    }
    
    func test_didReceiveUserNotificationPermissions_saysRequestedPermissionsGrantedWhenNoneAreRequsted() {
        let userNotificationsCapableDelegate = UserNotificationsCapableDelegate()
        userNotificationsCapableDelegate.application(UIApplication.shared, didRegister: UIUserNotificationSettings())
        
        
        XCTAssertEqual(userNotificationsCapableDelegate.grantedUserNotificationPermissions, UserNotificationPermissionsGranted.requested)
    }
    
    func test_didReceiveUserNotificationPermissions_saysNonePermissionsGrantedWhenAllAreRequstedAndNoneGranted() {
        let userNotificationsCapableDelegate = UserNotificationsCapableDelegate()
        userNotificationsCapableDelegate.userNotificationSettingsToPrefer = UIUserNotificationSettings(types: UIUserNotificationType(rawValue: (UIUserNotificationType.alert.rawValue | UIUserNotificationType.sound.rawValue | UIUserNotificationType.badge.rawValue)), categories: nil)
        userNotificationsCapableDelegate.application(UIApplication.shared, didRegister: UIUserNotificationSettings())
        
        XCTAssertEqual(userNotificationsCapableDelegate.grantedUserNotificationPermissions, UserNotificationPermissionsGranted.none)
    }
    
    func test_didReceiveUserNotificationPermissions_saysRequestedPermissionsGrantedWhenAllAreRequstedAndGranted() {
        let userNotificationsCapableDelegate = UserNotificationsCapableDelegate()
        let preferredUserNotificationTypes = UIUserNotificationType(rawValue: (UIUserNotificationType.alert.rawValue | UIUserNotificationType.sound.rawValue | UIUserNotificationType.badge.rawValue))
        userNotificationsCapableDelegate.userNotificationSettingsToPrefer = UIUserNotificationSettings(types: preferredUserNotificationTypes, categories: nil)
        userNotificationsCapableDelegate.application(UIApplication.shared, didRegister: UIUserNotificationSettings(types: preferredUserNotificationTypes, categories: nil))
        
        XCTAssertEqual(userNotificationsCapableDelegate.grantedUserNotificationPermissions, UserNotificationPermissionsGranted.requested)
    }
    
    func test_didReceiveUserNotificationPermissions_saysSomePermissionsGrantedWhenAllAreRequstedAndGranted() {
        let userNotificationsCapableDelegate = UserNotificationsCapableDelegate()
        let preferredUserNotificationTypes = UIUserNotificationType(rawValue: (UIUserNotificationType.alert.rawValue | UIUserNotificationType.sound.rawValue | UIUserNotificationType.badge.rawValue))
        userNotificationsCapableDelegate.userNotificationSettingsToPrefer = UIUserNotificationSettings(types: preferredUserNotificationTypes, categories: nil)
        userNotificationsCapableDelegate.application(UIApplication.shared, didRegister: UIUserNotificationSettings(types: UIUserNotificationType.badge, categories: nil))
        
        XCTAssertEqual(userNotificationsCapableDelegate.grantedUserNotificationPermissions, UserNotificationPermissionsGranted.partial(grantedPermissions: UIUserNotificationType.badge))
    }
}


// MARK: - UserNotificationsCapableDelegate


class UserNotificationsCapableDelegate: AppLaunchedDelegate, UserNotificationCapable {
    
    var userNotificationSettingsToPrefer = UIUserNotificationSettings()
    var requestedUserNotificationSettingsCallCount = 0
    func requestedUserNotificationSettings() -> UIUserNotificationSettings {
        requestedUserNotificationSettingsCallCount += 1
        return userNotificationSettingsToPrefer
    }
    
    var grantedUserNotificationPermissions = UserNotificationPermissionsGranted.none
    func didReceive(userNotificationPermissions: UserNotificationPermissionsGranted) {
        grantedUserNotificationPermissions = userNotificationPermissions
    }
}
