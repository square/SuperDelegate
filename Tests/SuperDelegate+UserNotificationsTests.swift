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
        XCTAssertTrue(userNotificationsCapableDelegate.application(UIApplication.sharedApplication(), willFinishLaunchingWithOptions: nil))
        XCTAssertTrue(userNotificationsCapableDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: nil))
        XCTAssertEqual(userNotificationsCapableDelegate.requestedUserNotificationSettingsCallCount, 1)
        
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication())
        // One call for testing if we've previously registered.
        XCTAssertEqual(userNotificationsCapableDelegate.requestedUserNotificationSettingsCallCount, 2)
        
        userNotificationsCapableDelegate.testing_resetAllData()
    }
    
    func test_requestUserNotificationPermissions_isCalledOnWillEnterForegroundIfPreviouslyCalled() {
        let userNotificationsCapableDelegate = UserNotificationsCapableDelegate()
        XCTAssertTrue(userNotificationsCapableDelegate.application(UIApplication.sharedApplication(), willFinishLaunchingWithOptions: nil))
        XCTAssertTrue(userNotificationsCapableDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: nil))
        // One call on willFinishLaunching is expected.
        XCTAssertEqual(userNotificationsCapableDelegate.requestedUserNotificationSettingsCallCount, 1)
        
        userNotificationsCapableDelegate.requestUserNotificationPermissions()
        // One call for registering, one call for noting that we registered.
        XCTAssertEqual(userNotificationsCapableDelegate.requestedUserNotificationSettingsCallCount, 3)
        
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication())
        // One call for testing if we've previously registered, one call for registering, one call for setting that we have registered.
        XCTAssertEqual(userNotificationsCapableDelegate.requestedUserNotificationSettingsCallCount, 6)
        
        userNotificationsCapableDelegate.testing_resetAllData()
    }
    
    func test_requestUserNotificationPermissions_isNotCalledOnWillEnterForegroundIfPreviouslyCalledWithDifferentNotificationTypes() {
        let userNotificationsCapableDelegate = UserNotificationsCapableDelegate()
        XCTAssertTrue(userNotificationsCapableDelegate.application(UIApplication.sharedApplication(), willFinishLaunchingWithOptions: nil))
        XCTAssertTrue(userNotificationsCapableDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: nil))
        XCTAssertEqual(userNotificationsCapableDelegate.requestedUserNotificationSettingsCallCount, 1)
        
        userNotificationsCapableDelegate.requestUserNotificationPermissions()
        // One call for registering, one call for noting that we registered.
        XCTAssertEqual(userNotificationsCapableDelegate.requestedUserNotificationSettingsCallCount, 3)
        
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication())
        // One call for testing if we've previously registered, one call for registering, one call for setting that we have registered.
        XCTAssertEqual(userNotificationsCapableDelegate.requestedUserNotificationSettingsCallCount, 6)
        
        // A new instance should be able to read from the same pref and register (or not) accordingly.
        let userNotificationsCapableDelegateWithDifferentUserNotificationPreferences = UserNotificationsCapableDelegate()
        userNotificationsCapableDelegateWithDifferentUserNotificationPreferences.userNotificationSettingsToPrefer = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil)
        
        XCTAssertTrue(userNotificationsCapableDelegateWithDifferentUserNotificationPreferences.application(UIApplication.sharedApplication(), willFinishLaunchingWithOptions: nil))
        XCTAssertEqual(userNotificationsCapableDelegateWithDifferentUserNotificationPreferences.requestedUserNotificationSettingsCallCount, 1)
        
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication())
        // One call for testing if we've previously registered, but none for registering.
        XCTAssertEqual(userNotificationsCapableDelegateWithDifferentUserNotificationPreferences.requestedUserNotificationSettingsCallCount, 1)
        
        userNotificationsCapableDelegate.testing_resetAllData()
        userNotificationsCapableDelegateWithDifferentUserNotificationPreferences.testing_resetAllData()
    }
    
    func test_didReceiveUserNotificationPermissions_saysRequestedPermissionsGrantedWhenNoneAreRequsted() {
        let userNotificationsCapableDelegate = UserNotificationsCapableDelegate()
        userNotificationsCapableDelegate.application(UIApplication.sharedApplication(), didRegisterUserNotificationSettings: UIUserNotificationSettings())
        
        XCTAssertEqual(userNotificationsCapableDelegate.grantedUserNotificationPermissions, UserNotificationPermissionsGranted.Requested)
    }
    
    func test_didReceiveUserNotificationPermissions_saysNonePermissionsGrantedWhenAllAreRequstedAndNoneGranted() {
        let userNotificationsCapableDelegate = UserNotificationsCapableDelegate()
        userNotificationsCapableDelegate.userNotificationSettingsToPrefer = UIUserNotificationSettings(forTypes: UIUserNotificationType(rawValue: (UIUserNotificationType.Alert.rawValue | UIUserNotificationType.Sound.rawValue | UIUserNotificationType.Badge.rawValue)), categories: nil)
        userNotificationsCapableDelegate.application(UIApplication.sharedApplication(), didRegisterUserNotificationSettings: UIUserNotificationSettings())
        
        XCTAssertEqual(userNotificationsCapableDelegate.grantedUserNotificationPermissions, UserNotificationPermissionsGranted.None)
    }
    
    func test_didReceiveUserNotificationPermissions_saysRequestedPermissionsGrantedWhenAllAreRequstedAndGranted() {
        let userNotificationsCapableDelegate = UserNotificationsCapableDelegate()
        let preferredUserNotificationTypes = UIUserNotificationType(rawValue: (UIUserNotificationType.Alert.rawValue | UIUserNotificationType.Sound.rawValue | UIUserNotificationType.Badge.rawValue))
        userNotificationsCapableDelegate.userNotificationSettingsToPrefer = UIUserNotificationSettings(forTypes: preferredUserNotificationTypes, categories: nil)
        userNotificationsCapableDelegate.application(UIApplication.sharedApplication(), didRegisterUserNotificationSettings: UIUserNotificationSettings(forTypes: preferredUserNotificationTypes, categories: nil))
        
        XCTAssertEqual(userNotificationsCapableDelegate.grantedUserNotificationPermissions, UserNotificationPermissionsGranted.Requested)
    }
    
    func test_didReceiveUserNotificationPermissions_saysSomePermissionsGrantedWhenAllAreRequstedAndGranted() {
        let userNotificationsCapableDelegate = UserNotificationsCapableDelegate()
        let preferredUserNotificationTypes = UIUserNotificationType(rawValue: (UIUserNotificationType.Alert.rawValue | UIUserNotificationType.Sound.rawValue | UIUserNotificationType.Badge.rawValue))
        userNotificationsCapableDelegate.userNotificationSettingsToPrefer = UIUserNotificationSettings(forTypes: preferredUserNotificationTypes, categories: nil)
        userNotificationsCapableDelegate.application(UIApplication.sharedApplication(), didRegisterUserNotificationSettings: UIUserNotificationSettings(forTypes: UIUserNotificationType.Badge, categories: nil))
        
        XCTAssertEqual(userNotificationsCapableDelegate.grantedUserNotificationPermissions, UserNotificationPermissionsGranted.Some(grantedPermissions: UIUserNotificationType.Badge))
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
    
    var grantedUserNotificationPermissions = UserNotificationPermissionsGranted.None
    func didReceiveUserNotificationPermissions(userNotificationPermissionsGranted: UserNotificationPermissionsGranted) {
        grantedUserNotificationPermissions = userNotificationPermissionsGranted
    }
}
