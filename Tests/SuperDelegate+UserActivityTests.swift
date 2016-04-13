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
            UIApplicationLaunchOptionsUserActivityDictionaryKey : [
                ApplicationLaunchOptionsUserActivityKey : NSUserActivity(activityType: userActivityType),
                UIApplicationLaunchOptionsUserActivityTypeKey : userActivityType
            ]
        ]
        
        XCTAssertFalse(userActivityCapableDelegate.application(UIApplication.sharedApplication(), willFinishLaunchingWithOptions: launchOptions))
        XCTAssertFalse(userActivityCapableDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: launchOptions))
        
        switch userActivityCapableDelegate.launchItem {
        case .NoItem:
            break
        default:
            XCTFail()
        }
    }
    
    func test_continueUserActivity_doesNotCallContinueUserActivityIfCanHandleUserActivityFails() {
        let userActivityCapableDelegate = UserActivityCapableDelegate()
        let userActivityType = "does this look like user activity to you?"
        
        userActivityCapableDelegate.shouldHandleNextUserActivity = false
        XCTAssertFalse(userActivityCapableDelegate.application(UIApplication.sharedApplication(), continueUserActivity: NSUserActivity(activityType: userActivityType)) { (_) in
            // Nothing to do here.
        })
        
        XCTAssertNil(userActivityCapableDelegate.continuedUserActivity)
    }
    
    func test_continueUserActivity_callsContinueUserActivityIfCanHandleUserActivitySucceeds() {
        let userActivityCapableDelegate = UserActivityCapableDelegate()
        let userActivity = NSUserActivity(activityType: "does this look like user activity to you?")
        
        userActivityCapableDelegate.loadInterfaceOnceWithLaunchItem(.NoItem)
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.sharedApplication(), continueUserActivity: userActivity) { (_) in
            // Nothing to do here.
        })
        
        XCTAssertEqual(userActivity, userActivityCapableDelegate.continuedUserActivity)
    }
    
    func test_applicationDidFinishLaunching_loadsInterfaceWithUserActivityIfCanHandleUserActivitySucceeds() {
        let userActivityCapableDelegate = UserActivityCapableDelegate()
        let userActivityType = "does this look like user activity to you?"
        
        let launchOptions = [
            UIApplicationLaunchOptionsUserActivityDictionaryKey : [
                ApplicationLaunchOptionsUserActivityKey : NSUserActivity(activityType: userActivityType),
                UIApplicationLaunchOptionsUserActivityTypeKey : userActivityType
            ]
        ]
        
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.sharedApplication(), willFinishLaunchingWithOptions: launchOptions))
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: launchOptions))
        
        switch userActivityCapableDelegate.launchItem {
        case let .UserActivityItem(launchUserActivity):
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
            UIApplicationLaunchOptionsUserActivityDictionaryKey : [
                ApplicationLaunchOptionsUserActivityKey : userActivity,
                UIApplicationLaunchOptionsUserActivityTypeKey : userActivityType
            ]
        ]
        
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.sharedApplication(), willFinishLaunchingWithOptions: launchOptions))
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: launchOptions))
        
        switch userActivityCapableDelegate.launchItem {
        case let .UserActivityItem(launchUserActivity):
            XCTAssertEqual(userActivityType, launchUserActivity.activityType)
        default:
            XCTFail()
        }
        
        XCTAssertNil(userActivityCapableDelegate.continuedUserActivity)
        
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.sharedApplication(), continueUserActivity: userActivity, restorationHandler: { (_) in
            // Nothing to do here
        }))
        
        XCTAssertNil(userActivityCapableDelegate.continuedUserActivity)
    }
    
    func test_continueUserActivity_doesNotDropUserActivityDeliveredToLoadInterfaceWithLaunchItemAfterApplicationWillEnterForeground() {
        let userActivityCapableDelegate = UserActivityCapableDelegate()
        let userActivityType = "does this look like user activity to you?"
        let userActivity = NSUserActivity(activityType: userActivityType)
        
        
        let launchOptions = [
            UIApplicationLaunchOptionsUserActivityDictionaryKey : [
                ApplicationLaunchOptionsUserActivityKey : userActivity,
                UIApplicationLaunchOptionsUserActivityTypeKey : userActivityType
            ]
        ]
        
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.sharedApplication(), willFinishLaunchingWithOptions: launchOptions))
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: launchOptions))
        
        switch userActivityCapableDelegate.launchItem {
        case let .UserActivityItem(launchUserActivity):
            XCTAssertEqual(userActivityType, launchUserActivity.activityType)
        default:
            XCTFail()
        }
        
        XCTAssertNil(userActivityCapableDelegate.continuedUserActivity)
        
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication())
        
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.sharedApplication(), continueUserActivity: userActivity, restorationHandler: { (_) in
            // Nothing to do here
        }))
        
        XCTAssertEqual(userActivityCapableDelegate.continuedUserActivity, userActivity)
    }
    
    func test_continueUserActivity_doesNotDropUserActivityDifferentThanUserActivityDeliveredToLoadInterfaceWithLaunchItem() {
        let userActivityCapableDelegate = UserActivityCapableDelegate()
        let userActivityType = "does this look like user activity to you?"
        let userActivity = NSUserActivity(activityType: userActivityType)
        
        
        let launchOptions = [
            UIApplicationLaunchOptionsUserActivityDictionaryKey : [
                ApplicationLaunchOptionsUserActivityKey : userActivity,
                UIApplicationLaunchOptionsUserActivityTypeKey : userActivityType
            ]
        ]
        
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.sharedApplication(), willFinishLaunchingWithOptions: launchOptions))
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: launchOptions))
        
        switch userActivityCapableDelegate.launchItem {
        case let .UserActivityItem(launchUserActivity):
            XCTAssertEqual(userActivityType, launchUserActivity.activityType)
        default:
            XCTFail()
        }
        
        XCTAssertNil(userActivityCapableDelegate.continuedUserActivity)
        
        let anotherUserActivity = NSUserActivity(activityType: "Some other user activity")
        XCTAssertTrue(userActivityCapableDelegate.application(UIApplication.sharedApplication(), continueUserActivity: anotherUserActivity, restorationHandler: { (_) in
            // Nothing to do here
        }))
        
        XCTAssertEqual(userActivityCapableDelegate.continuedUserActivity, anotherUserActivity)
    }
}


// MARK: - UserActivityCapableDelegate


class UserActivityCapableDelegate: AppLaunchedDelegate, UserActivityCapable {
    var shouldHandleNextUserActivity = true
    func canHandleUserActivity(userActivity: NSUserActivity) -> Bool {
        return shouldHandleNextUserActivity
    }
    
    var continuedUserActivity: NSUserActivity?
    func continueUserActivity(userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        continuedUserActivity = userActivity
        return true
    }
}
