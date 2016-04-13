//
//  SuperDelegate+LocalNotificationsTests.swift
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


class SuperDelegateLocalNotificationTests: SuperDelegateTests {
    
    
    // MARK: - Behavioral Tests
    
    
    // MARK: LocalNotificationCapableDelegate Tests
    
    
    func test_applicationDidFinishLaunching_loadsInterfaceWithLaunchItem() {
        let localNotificationCapableDelegate = LocalNotificationCapableDelegate()
        let localNotification = UILocalNotification()
        localNotification.alertBody = "somebody"
        XCTAssertTrue(localNotificationCapableDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: [UIApplicationLaunchOptionsLocalNotificationKey : localNotification]))
        
        switch localNotificationCapableDelegate.launchItem {
        case let .LocalNotificationItem(launchLocalNotification):
            XCTAssertEqual(localNotification, launchLocalNotification)
        default:
            XCTFail()
        }
    }
    
    func test_receivingLocalNotification_notifiesIfUserTapped() {
        let localNotificationCapableDelegate = LocalNotificationCapableDelegate()
        localNotificationCapableDelegate.loadInterfaceOnceWithLaunchItem(.NoItem)
        
        let localNotification = UILocalNotification()
        localNotification.alertBody = "somebody"
        localNotificationCapableDelegate.application(UIApplication.sharedApplication(), didReceiveLocalNotification: localNotification)
        
        XCTAssertEqual(localNotification, localNotificationCapableDelegate.receivedLocalNotification)
        XCTAssertEqual(localNotificationCapableDelegate.receivedNotificationOrigin, UserNotificationOrigin.UserTappedToBringAppToForeground)
    }
    
    func test_receivingLocalNotification_notifiesIfAppInForeground() {
        let localNotificationCapableDelegate = LocalNotificationCapableDelegate()
        localNotificationCapableDelegate.loadInterfaceOnceWithLaunchItem(.NoItem)
        localNotificationCapableDelegate.applicationIsInForeground = true
        
        let localNotification = UILocalNotification()
        localNotification.alertBody = "somebody"
        localNotificationCapableDelegate.application(UIApplication.sharedApplication(), didReceiveLocalNotification: localNotification)
        
        XCTAssertEqual(localNotification, localNotificationCapableDelegate.receivedLocalNotification)
        XCTAssertEqual(localNotificationCapableDelegate.receivedNotificationOrigin, UserNotificationOrigin.DeliveredWhileInForground)
    }
    
    func test_didReceiveLocalNotification_dropsRemoteNotificationDeliveredToLoadInterfaceWithLaunchItem() {
        let localNotificationCapableDelegate = LocalNotificationCapableDelegate()
        let localNotification = UILocalNotification()
        localNotification.alertBody = "somebody"
        XCTAssertTrue(localNotificationCapableDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: [UIApplicationLaunchOptionsLocalNotificationKey : localNotification]))
        
        switch localNotificationCapableDelegate.launchItem {
        case let .LocalNotificationItem(launchLocalNotification):
            XCTAssertEqual(localNotification, launchLocalNotification)
        default:
            XCTFail()
        }
        
        XCTAssertNil(localNotificationCapableDelegate.receivedLocalNotification)
        
        localNotificationCapableDelegate.application(UIApplication.sharedApplication(), didReceiveLocalNotification: localNotification)
        
        XCTAssertNil(localNotificationCapableDelegate.receivedLocalNotification)
    }
    
    func test_didReceiveLocalNotification_doesNotDropLocalNotificationDeliveredToLoadInterfaceWithLaunchItemAfterApplicationWillEnterForeground() {
        let localNotificationCapableDelegate = LocalNotificationCapableDelegate()
        let localNotification = UILocalNotification()
        localNotification.alertBody = "somebody"
        XCTAssertTrue(localNotificationCapableDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: [UIApplicationLaunchOptionsLocalNotificationKey : localNotification]))
        
        switch localNotificationCapableDelegate.launchItem {
        case let .LocalNotificationItem(launchLocalNotification):
            XCTAssertEqual(localNotification, launchLocalNotification)
        default:
            XCTFail()
        }
        
        XCTAssertNil(localNotificationCapableDelegate.receivedLocalNotification)
        
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication())
        
        localNotificationCapableDelegate.application(UIApplication.sharedApplication(), didReceiveLocalNotification: localNotification)
        
        XCTAssertEqual(localNotificationCapableDelegate.receivedLocalNotification, localNotification)
    }
    
    func test_didReceiveLocalNotification_doesNotDropLocalNotificationDifferentThanLocalNotificationDeliveredToLoadInterfaceWithLaunchItem() {
        let localNotificationCapableDelegate = LocalNotificationCapableDelegate()
        let localNotification = UILocalNotification()
        localNotification.alertBody = "somebody"
        XCTAssertTrue(localNotificationCapableDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: [UIApplicationLaunchOptionsLocalNotificationKey : localNotification]))
        
        switch localNotificationCapableDelegate.launchItem {
        case let .LocalNotificationItem(launchLocalNotification):
            XCTAssertEqual(localNotification, launchLocalNotification)
        default:
            XCTFail()
        }
        
        XCTAssertNil(localNotificationCapableDelegate.receivedLocalNotification)
        
        let otherReceivedLocalNotification = UILocalNotification()
        localNotificationCapableDelegate.application(UIApplication.sharedApplication(), didReceiveLocalNotification: otherReceivedLocalNotification)
        
        XCTAssertEqual(localNotificationCapableDelegate.receivedLocalNotification, otherReceivedLocalNotification)
    }
    
    
    // MARK: LocalNotificationActionCapableDelegate Tests
    
    
    func test_receivingLocalNotificationAction_notifies() {
        let localNotificationActionCapableDelegate = LocalNotificationActionCapableDelegate()
        let localNotification = UILocalNotification()
        localNotification.alertBody = "somebody"
        let actionIdentifier = "some action"
        
        var completionHandlerExecuted = false
        localNotificationActionCapableDelegate.application(UIApplication.sharedApplication(), handleActionWithIdentifier: actionIdentifier, forLocalNotification: localNotification) { 
            completionHandlerExecuted = true
        }
        
        XCTAssertTrue(completionHandlerExecuted)
        XCTAssertEqual(localNotification, localNotificationActionCapableDelegate.handledLocalNotification)
        XCTAssertEqual(actionIdentifier, localNotificationActionCapableDelegate.handledActionIdentifier)
        XCTAssertNil(localNotificationActionCapableDelegate.handledResponseInfo)
        
        
    }
    
    func test_receivingLocalNotificationWithResponseInfoAction_notifies() {
        let localNotificationActionCapableDelegate = LocalNotificationActionCapableDelegate()
        let localNotification = UILocalNotification()
        localNotification.alertBody = "somebody"
        let actionIdentifier = "some action"
        let responseInfo = ["a response" : "object"]
        
        var completionHandlerExecuted = false
        localNotificationActionCapableDelegate.application(UIApplication.sharedApplication(), handleActionWithIdentifier: actionIdentifier, forLocalNotification: localNotification, withResponseInfo: responseInfo) {
            completionHandlerExecuted = true
        }
        
        XCTAssertTrue(completionHandlerExecuted)
        XCTAssertEqual(localNotification, localNotificationActionCapableDelegate.handledLocalNotification)
        XCTAssertEqual(actionIdentifier, localNotificationActionCapableDelegate.handledActionIdentifier)
        XCTAssertEqual(responseInfo, localNotificationActionCapableDelegate.handledResponseInfo as! [String : String])
    }
}


// MARK: - LocalNotificationCapableDelegate


class LocalNotificationCapableDelegate: UserNotificationsCapableDelegate, LocalNotificationCapable {
    
    var receivedLocalNotification: UILocalNotification?
    var receivedNotificationOrigin = UserNotificationOrigin.DeliveredWhileInBackground
    func didReceiveLocalNotification(localNotification: UILocalNotification, notificationOrigin: UserNotificationOrigin) {
        receivedLocalNotification = localNotification
        receivedNotificationOrigin = notificationOrigin
    }
}


// MARK: - LocalNotificationActionCapableDelegate


class LocalNotificationActionCapableDelegate: LocalNotificationCapableDelegate, LocalNotificationActionCapable {
    
    var handledActionIdentifier: String? = ""
    var handledLocalNotification = UILocalNotification()
    var handledResponseInfo: [String : AnyObject]? = nil
    func handleLocalNotificationActionWithIdentifier(actionIdentifier: String?, forLocalNotification notification: UILocalNotification, withResponseInfo responseInfo: [String : AnyObject]?, completionHandler: () -> Void) {
        handledActionIdentifier = actionIdentifier
        handledLocalNotification = notification
        handledResponseInfo = responseInfo
        completionHandler()
    }
}
