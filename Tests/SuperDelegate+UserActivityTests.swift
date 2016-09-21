//
//  SuperDelegate+UserActivityTests.swift
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


class SuperDelegateUserActivityTests: SuperDelegateTests {
    
    
    // MARK: - Behavioral Tests
    
    
    func test_applicationDidFinishLaunching_doesNotLoadInterfaceWithUserActivityIfCanHandleUserActivityFails() {
        let userActivityCapableDelegate = UserActivityCapableDelegate()
        let userActivityType = "does this look like user activity to you?"
        
        userActivityCapableDelegate.shouldHandleNextUserActivity = false
        let launchOptions = [
            UIApplicationLaunchOptionsKey.userActivityDictionary : [
                UIApplicationLaunchOptionsKey.userActivity : NSUserActivity(activityType: userActivityType),
                UIApplicationLaunchOptionsKey.userActivityType : userActivityType
            ]
        ]
        
        XCTAssertFalse(userActivityCapableDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: launchOptions))
        XCTAssertFalse(userActivityCapableDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: launchOptions))
        
        switch userActivityCapableDelegate.launchItem {
        case .none:
            break
        default:
            XCTFail()
        }
    }
    
    func test_continueUserActivity_doesNotCallContinueUserActivityIfCanHandleUserActivityFails() {
        let userActivityCapableDelegate = UserActivityCapableDelegate()
        let userActivityType = "does this look like user activity to you?"
        
        userActivityCapableDelegate.shouldHandleNextUserActivity = false
        XCTAssertFalse(userActivityCapableDelegate.application(UIApplication.shared, continue: NSUserActivity(activityType: userActivityType)) { (_) in
            // Nothing to do here.
            }
        )
        
        XCTAssertNil(userActivityCapableDelegate.continuedUserActivity)
    }
    
    func test_continueUserActivity_callsContinueUserActivityIfCanHandleUserActivitySucceeds() {
        let userActivityCapableDelegate = UserActivityCapableDelegate()
        let userActivity = NSUserActivity(activityType: "does this look like user activity to you?")
        
        userActivityCapableDelegate.loadInterfaceOnce(with: .none)
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.shared, continue: userActivity) { (_) in
            // Nothing to do here.
            })
        
        XCTAssertEqual(userActivity, userActivityCapableDelegate.continuedUserActivity)
    }
    
    func test_applicationDidFinishLaunching_loadsInterfaceWithUserActivityIfCanHandleUserActivitySucceeds() {
        let userActivityCapableDelegate = UserActivityCapableDelegate()
        let userActivityType = "does this look like user activity to you?"
        
        let launchOptions = [
            UIApplicationLaunchOptionsKey.userActivityDictionary : [
                UIApplicationLaunchOptionsKey.userActivity : NSUserActivity(activityType: userActivityType),
                UIApplicationLaunchOptionsKey.userActivityType : userActivityType
            ]
        ]
        
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: launchOptions))
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: launchOptions))
        
        switch userActivityCapableDelegate.launchItem {
        case let .userActivity(launchUserActivity):
            XCTAssertEqual(userActivityType, launchUserActivity.activityType)
        default:
            XCTFail()
        }
    }
    
    func test_continueUserActivity_dropsUserActivityDeliveredToLoadInterfaceWithLaunchItem() {
        let userActivityCapableDelegate = UserActivityCapableDelegate()
        let userActivityType = "does this look like user activity to you?"
        let userActivity = NSUserActivity(activityType: userActivityType)
        
        let launchOptions = [
            UIApplicationLaunchOptionsKey.userActivityDictionary : [
                UIApplicationLaunchOptionsKey.userActivity : userActivity,
                UIApplicationLaunchOptionsKey.userActivityType : userActivityType
            ]
        ]
        
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: launchOptions))
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: launchOptions))
        
        switch userActivityCapableDelegate.launchItem {
        case let .userActivity(launchUserActivity):
            XCTAssertEqual(userActivityType, launchUserActivity.activityType)
        default:
            XCTFail()
        }
        
        XCTAssertNil(userActivityCapableDelegate.continuedUserActivity)
        
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.shared, continue: userActivity, restorationHandler: { (_) in
            // Nothing to do here
        }))
        
        XCTAssertNil(userActivityCapableDelegate.continuedUserActivity)
    }
    
    func test_continueUserActivity_doesNotDropUserActivityDeliveredToLoadInterfaceWithLaunchItemAfterApplicationWillEnterForeground() {
        let userActivityCapableDelegate = UserActivityCapableDelegate()
        let userActivityType = "does this look like user activity to you?"
        let userActivity = NSUserActivity(activityType: userActivityType)
        
        let launchOptions = [
            UIApplicationLaunchOptionsKey.userActivityDictionary : [
                UIApplicationLaunchOptionsKey.userActivity : userActivity,
                UIApplicationLaunchOptionsKey.userActivityType : userActivityType
            ]
        ]
        
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: launchOptions))
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: launchOptions))
        
        switch userActivityCapableDelegate.launchItem {
        case let .userActivity(launchUserActivity):
            XCTAssertEqual(userActivityType, launchUserActivity.activityType)
        default:
            XCTFail()
        }
        
        XCTAssertNil(userActivityCapableDelegate.continuedUserActivity)
        
        NotificationCenter.default.post(name: NSNotification.Name.UIApplicationWillEnterForeground, object: UIApplication.shared)
        
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.shared, continue: userActivity, restorationHandler: { (_) in
            // Nothing to do here
        }))
        
        XCTAssertEqual(userActivityCapableDelegate.continuedUserActivity, userActivity)
    }
    
    func test_continueUserActivity_doesNotDropUserActivityDifferentThanUserActivityDeliveredToLoadInterfaceWithLaunchItem() {
        let userActivityCapableDelegate = UserActivityCapableDelegate()
        let userActivityType = "does this look like user activity to you?"
        let userActivity = NSUserActivity(activityType: userActivityType)
        
        let launchOptions = [
            UIApplicationLaunchOptionsKey.userActivityDictionary : [
                UIApplicationLaunchOptionsKey.userActivity : userActivity,
                UIApplicationLaunchOptionsKey.userActivityType : userActivityType
            ]
        ]
        
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: launchOptions))
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: launchOptions))
        
        switch userActivityCapableDelegate.launchItem {
        case let .userActivity(launchUserActivity):
            XCTAssertEqual(userActivityType, launchUserActivity.activityType)
        default:
            XCTFail()
        }
        
        XCTAssertNil(userActivityCapableDelegate.continuedUserActivity)
        
        let anotherUserActivity = NSUserActivity(activityType: "Some other user activity")
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.shared, continue: anotherUserActivity, restorationHandler: { (_) in
            // Nothing to do here
        }))
        
        XCTAssertEqual(userActivityCapableDelegate.continuedUserActivity, anotherUserActivity)
    }
}


// MARK: - UserActivityCapableDelegate


class UserActivityCapableDelegate: AppLaunchedDelegate, UserActivityCapable {
    var shouldHandleNextUserActivity = true
    func canResume(userActivity: NSUserActivity) -> Bool {
        return shouldHandleNextUserActivity
    }
    
    var continuedUserActivity: NSUserActivity?
    func resume(userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Swift.Void) -> Bool {
        continuedUserActivity = userActivity
        return true
    }
}
