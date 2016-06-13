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
        XCTAssertTrue(localNotificationCapableDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: [UIApplicationLaunchOptionsKey.localNotification : localNotification]))
        
        switch localNotificationCapableDelegate.launchItem {
        case let .localNotification(launchLocalNotification):
            XCTAssertEqual(localNotification, launchLocalNotification)
        default:
            XCTFail()
        }
    }
    
    func test_receivingLocalNotification_notifiesIfUserTapped() {
        let localNotificationCapableDelegate = LocalNotificationCapableDelegate()
        localNotificationCapableDelegate.loadInterfaceOnce(with: .none)
        
        let localNotification = UILocalNotification()
        localNotification.alertBody = "somebody"
        localNotificationCapableDelegate.application(UIApplication.shared, didReceive: localNotification)
        
        XCTAssertEqual(localNotification, localNotificationCapableDelegate.receivedLocalNotification)
        XCTAssertEqual(localNotificationCapableDelegate.receivedNotificationOrigin, UserNotificationOrigin.userTappedToBringAppToForeground)
    }
    
    func test_receivingLocalNotification_notifiesIfAppInForeground() {
        let localNotificationCapableDelegate = LocalNotificationCapableDelegate()
        localNotificationCapableDelegate.loadInterfaceOnce(with: .none)
        localNotificationCapableDelegate.applicationIsInForeground = true
        
        let localNotification = UILocalNotification()
        localNotification.alertBody = "somebody"
        localNotificationCapableDelegate.application(UIApplication.shared, didReceive: localNotification)
        
        XCTAssertEqual(localNotification, localNotificationCapableDelegate.receivedLocalNotification)
        XCTAssertEqual(localNotificationCapableDelegate.receivedNotificationOrigin, UserNotificationOrigin.deliveredWhileInForeground)
    }
    
    func test_didReceive_dropsRemoteNotificationDeliveredToLoadInterfaceWithLaunchItem() {
        let localNotificationCapableDelegate = LocalNotificationCapableDelegate()
        let localNotification = UILocalNotification()
        localNotification.alertBody = "somebody"
        XCTAssertTrue(localNotificationCapableDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: [UIApplicationLaunchOptionsKey.localNotification : localNotification]))
        
        switch localNotificationCapableDelegate.launchItem {
        case let .localNotification(launchLocalNotification):
            XCTAssertEqual(localNotification, launchLocalNotification)
        default:
            XCTFail()
        }
        
        XCTAssertNil(localNotificationCapableDelegate.receivedLocalNotification)
        
        localNotificationCapableDelegate.application(UIApplication.shared, didReceive: localNotification)
        
        XCTAssertNil(localNotificationCapableDelegate.receivedLocalNotification)
    }
    
    func test_didReceive_doesNotDropLocalNotificationDeliveredToLoadInterfaceWithLaunchItemAfterApplicationWillEnterForeground() {
        let localNotificationCapableDelegate = LocalNotificationCapableDelegate()
        let localNotification = UILocalNotification()
        localNotification.alertBody = "somebody"
        XCTAssertTrue(localNotificationCapableDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: [UIApplicationLaunchOptionsKey.localNotification : localNotification]))
        
        switch localNotificationCapableDelegate.launchItem {
        case let .localNotification(launchLocalNotification):
            XCTAssertEqual(localNotification, launchLocalNotification)
        default:
            XCTFail()
        }
        
        XCTAssertNil(localNotificationCapableDelegate.receivedLocalNotification)
        
        NotificationCenter.default.post(name: NSNotification.Name.UIApplicationWillEnterForeground, object: UIApplication.shared)
        
        localNotificationCapableDelegate.application(UIApplication.shared, didReceive: localNotification)
        
        XCTAssertEqual(localNotificationCapableDelegate.receivedLocalNotification, localNotification)
    }
    
    func test_didReceive_doesNotDropLocalNotificationDifferentThanLocalNotificationDeliveredToLoadInterfaceWithLaunchItem() {
        let localNotificationCapableDelegate = LocalNotificationCapableDelegate()
        let localNotification = UILocalNotification()
        localNotification.alertBody = "somebody"
        XCTAssertTrue(localNotificationCapableDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: [UIApplicationLaunchOptionsKey.localNotification : localNotification]))
        
        switch localNotificationCapableDelegate.launchItem {
        case let .localNotification(launchLocalNotification):
            XCTAssertEqual(localNotification, launchLocalNotification)
        default:
            XCTFail()
        }
        
        XCTAssertNil(localNotificationCapableDelegate.receivedLocalNotification)
        
        let otherReceivedLocalNotification = UILocalNotification()
        localNotificationCapableDelegate.application(UIApplication.shared, didReceive: otherReceivedLocalNotification)
        
        XCTAssertEqual(localNotificationCapableDelegate.receivedLocalNotification, otherReceivedLocalNotification)
    }
    
    
    // MARK: LocalNotificationActionCapableDelegate Tests
    
    
    func test_receivingLocalNotificationAction_notifies() {
        let localNotificationActionCapableDelegate = LocalNotificationActionCapableDelegate()
        let localNotification = UILocalNotification()
        localNotification.alertBody = "somebody"
        let actionIdentifier = "some action"
        
        var completionHandlerExecuted = false
        localNotificationActionCapableDelegate.application(UIApplication.shared, handleActionWithIdentifier: actionIdentifier, for: localNotification) {
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
        localNotificationActionCapableDelegate.application(UIApplication.shared, handleActionWithIdentifier: actionIdentifier, for: localNotification, withResponseInfo: responseInfo) {
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
    var receivedNotificationOrigin = UserNotificationOrigin.deliveredWhileInBackground
    func didReceive(localNotification: UILocalNotification, origin: UserNotificationOrigin) {
        receivedLocalNotification = localNotification
        receivedNotificationOrigin = origin
    }
}


// MARK: - LocalNotificationActionCapableDelegate


class LocalNotificationActionCapableDelegate: LocalNotificationCapableDelegate, LocalNotificationActionCapable {
    
    var handledActionIdentifier: String? = ""
    var handledLocalNotification = UILocalNotification()
    var handledResponseInfo: [String : Any]? = nil
    func handleLocalNotification(actionIdentifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [String : Any]?, completionHandler: @escaping () -> Swift.Void) {
        handledActionIdentifier = actionIdentifier
        handledLocalNotification = notification
        handledResponseInfo = responseInfo
        completionHandler()
    }
}
