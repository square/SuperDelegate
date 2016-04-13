//
//  SuperDelegate+OpenURLTests.swift
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


class SuperDelegateOpenURLTests: SuperDelegateTests {
    
    
    // MARK: - Behavioral Tests
    
    
    func test_applicationDidFinishLaunching_doesNotLoadInterfaceWithURLIfCanOpenLaunchURLFails() {
        let openURLCapableDelegate = OpenURLCapableDelegate()
        let url = NSURL(string: "cash.me/$dan")!
        let sourceBundleID = "com.squareup.cash"
        let annotation = 1
        let copyBeforeUse = true
        
        openURLCapableDelegate.shouldOpenNextURL = false
        let launchOptions: [String : AnyObject]
        if #available(iOS 9.0, *) {
            launchOptions = [
                UIApplicationLaunchOptionsURLKey : url,
                UIApplicationLaunchOptionsSourceApplicationKey : sourceBundleID,
                UIApplicationLaunchOptionsAnnotationKey : annotation,
                UIApplicationOpenURLOptionsOpenInPlaceKey : copyBeforeUse
            ]
        } else {
            launchOptions = [
                UIApplicationLaunchOptionsURLKey : url,
                UIApplicationLaunchOptionsSourceApplicationKey : sourceBundleID,
                UIApplicationLaunchOptionsAnnotationKey : annotation
            ]
        }
        
        XCTAssertFalse(openURLCapableDelegate.application(UIApplication.sharedApplication(), willFinishLaunchingWithOptions: launchOptions))
        XCTAssertFalse(openURLCapableDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: launchOptions))
        
        switch openURLCapableDelegate.launchItem {
        case .NoItem:
            break
        default:
            XCTFail()
        }
    }
        
    func test_applicationDidFinishLaunching_passesThroughOptions() {
        let openURLCapableDelegate = OpenURLCapableDelegate()
        let url = NSURL(string: "cash.me/$dan")!
        let sourceBundleID = "com.squareup.cash"
        let annotation = 1
        let copyBeforeUse = true
        
        if #available(iOS 9.0, *) {
            XCTAssertTrue(
                openURLCapableDelegate.application(UIApplication.sharedApplication(),
                    didFinishLaunchingWithOptions: [
                        UIApplicationLaunchOptionsURLKey : url,
                        UIApplicationLaunchOptionsSourceApplicationKey : sourceBundleID,
                        UIApplicationLaunchOptionsAnnotationKey : annotation,
                        UIApplicationOpenURLOptionsOpenInPlaceKey : copyBeforeUse
                    ]
                )
            )
        } else {
            XCTAssertTrue(
                openURLCapableDelegate.application(UIApplication.sharedApplication(),
                    didFinishLaunchingWithOptions: [
                        UIApplicationLaunchOptionsURLKey : url,
                        UIApplicationLaunchOptionsSourceApplicationKey : sourceBundleID,
                        UIApplicationLaunchOptionsAnnotationKey : annotation
                    ]
                )
            )
        }
        
        switch openURLCapableDelegate.launchItem {
        case let .OpenURLItem(urlToOpen):
            XCTAssertEqual(urlToOpen.url, url)
            XCTAssertEqual(urlToOpen.sourceApplicationBundleID, sourceBundleID)
            XCTAssertEqual(urlToOpen.annotation as? Int, annotation)
            XCTAssertEqual(urlToOpen.copyBeforeUse, copyBeforeUse)
        default:
            XCTFail()
        }
    }
    
    func test_openURL_options_passesThroughOptions() {
        let openURLCapableDelegate = OpenURLCapableDelegate()
        openURLCapableDelegate.loadInterfaceOnceWithLaunchItem(.NoItem)
        
        let url = NSURL(string: "cash.me/$dan")!
        let sourceBundleID = "com.squareup.cash"
        let annotation = 1
        let copyBeforeUse = true
        
        if #available(iOS 9.0, *) {
            XCTAssertTrue(
                openURLCapableDelegate.application(UIApplication.sharedApplication(),
                    openURL: url,
                    options: [
                        UIApplicationOpenURLOptionsSourceApplicationKey : sourceBundleID,
                        UIApplicationOpenURLOptionsAnnotationKey : annotation,
                        UIApplicationOpenURLOptionsOpenInPlaceKey : copyBeforeUse
                    ]
                )
            )
        } else {
            XCTAssertTrue(openURLCapableDelegate.application(UIApplication.sharedApplication(), openURL: url, sourceApplication: sourceBundleID, annotation: annotation))
        }
        
        XCTAssertEqual(openURLCapableDelegate.handledURLToOpen?.url, url)
        XCTAssertEqual(openURLCapableDelegate.handledURLToOpen?.sourceApplicationBundleID, sourceBundleID)
        XCTAssertEqual(openURLCapableDelegate.handledURLToOpen?.annotation as? Int, annotation)
        XCTAssertEqual(openURLCapableDelegate.handledURLToOpen?.copyBeforeUse, copyBeforeUse)
    }
    
    func test_openURL_sourceApplication_annotation_passesThroughOptions() {
        let openURLCapableDelegate = OpenURLCapableDelegate()
        openURLCapableDelegate.loadInterfaceOnceWithLaunchItem(.NoItem)
        
        let url = NSURL(string: "cash.me/$dan")!
        let sourceBundleID = "com.squareup.cash"
        let annotation = 1
        
        XCTAssertTrue(openURLCapableDelegate.application(UIApplication.sharedApplication(), openURL: url, sourceApplication: sourceBundleID, annotation: annotation))
        
        XCTAssertEqual(openURLCapableDelegate.handledURLToOpen?.url, url)
        XCTAssertEqual(openURLCapableDelegate.handledURLToOpen?.sourceApplicationBundleID, sourceBundleID)
        XCTAssertEqual(openURLCapableDelegate.handledURLToOpen?.annotation as? Int, annotation)
        XCTAssertFalse(openURLCapableDelegate.handledURLToOpen?.copyBeforeUse ?? true)
    }
    
     func test_openURL_dropsURLDeliveredToLoadInterfaceWithLaunchItem() {
        let openURLCapableDelegate = OpenURLCapableDelegate()
        let url = NSURL(string: "cash.me/$dan")!
        let sourceBundleID = "com.squareup.cash"
        let annotation = 1
        let copyBeforeUse = true
        
        openURLCapableDelegate.shouldOpenNextURL = true
        let launchOptions: [String : AnyObject]
        if #available(iOS 9.0, *) {
            launchOptions = [
                UIApplicationLaunchOptionsURLKey : url,
                UIApplicationLaunchOptionsSourceApplicationKey : sourceBundleID,
                UIApplicationLaunchOptionsAnnotationKey : annotation,
                UIApplicationOpenURLOptionsOpenInPlaceKey : copyBeforeUse
            ]
        } else {
            launchOptions = [
                UIApplicationLaunchOptionsURLKey : url,
                UIApplicationLaunchOptionsSourceApplicationKey : sourceBundleID,
                UIApplicationLaunchOptionsAnnotationKey : annotation
            ]
        }
        
        XCTAssertTrue(openURLCapableDelegate.application(UIApplication.sharedApplication(), willFinishLaunchingWithOptions: launchOptions))
        XCTAssertTrue(openURLCapableDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: launchOptions))
        
        switch openURLCapableDelegate.launchItem {
        case .OpenURLItem:
            break
        default:
            XCTFail()
        }
        
        XCTAssertNotNil(openURLCapableDelegate.handledURLToOpen)
        openURLCapableDelegate.handledURLToOpen = nil
        
        if #available(iOS 9.0, *) {
            XCTAssertTrue(openURLCapableDelegate.application(UIApplication.sharedApplication(), openURL: url, options: [:]))
        } else {
            XCTAssertTrue(openURLCapableDelegate.application(UIApplication.sharedApplication(), openURL: url, sourceApplication: sourceBundleID, annotation: annotation))
        }
        
        XCTAssertNil(openURLCapableDelegate.handledURLToOpen)
     }
    
    func test_openURL_doesNotDropURLDeliveredToLoadInterfaceWithLaunchItemAfterApplicationWillEnterForeground() {
        let openURLCapableDelegate = OpenURLCapableDelegate()
        let url = NSURL(string: "cash.me/$dan")!
        let sourceBundleID = "com.squareup.cash"
        let annotation = 1
        let copyBeforeUse = true
        
        openURLCapableDelegate.shouldOpenNextURL = true
        let launchOptions: [String : AnyObject]
        if #available(iOS 9.0, *) {
            launchOptions = [
                UIApplicationLaunchOptionsURLKey : url,
                UIApplicationLaunchOptionsSourceApplicationKey : sourceBundleID,
                UIApplicationLaunchOptionsAnnotationKey : annotation,
                UIApplicationOpenURLOptionsOpenInPlaceKey : copyBeforeUse
            ]
        } else {
            launchOptions = [
                UIApplicationLaunchOptionsURLKey : url,
                UIApplicationLaunchOptionsSourceApplicationKey : sourceBundleID,
                UIApplicationLaunchOptionsAnnotationKey : annotation
            ]
        }
        
        XCTAssertTrue(openURLCapableDelegate.application(UIApplication.sharedApplication(), willFinishLaunchingWithOptions: launchOptions))
        XCTAssertTrue(openURLCapableDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: launchOptions))
        
        switch openURLCapableDelegate.launchItem {
        case .OpenURLItem:
            break
        default:
            XCTFail()
        }
        
        XCTAssertNotNil(openURLCapableDelegate.handledURLToOpen)
        openURLCapableDelegate.handledURLToOpen = nil
        
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication())
        
        if #available(iOS 9.0, *) {
            XCTAssertTrue(openURLCapableDelegate.application(UIApplication.sharedApplication(), openURL: url, options: [:]))
        } else {
            XCTAssertTrue(openURLCapableDelegate.application(UIApplication.sharedApplication(), openURL: url, sourceApplication: sourceBundleID, annotation: annotation))
        }
        
        XCTAssertEqual(openURLCapableDelegate.handledURLToOpen?.url, url)
    }
    
    func test_openURL_doesNotDropURLDifferentThanURLDeliveredToLoadInterfaceWithLaunchItem() {
        let openURLCapableDelegate = OpenURLCapableDelegate()
        let url = NSURL(string: "cash.me/$dan")!
        let sourceBundleID = "com.squareup.cash"
        let annotation = 1
        let copyBeforeUse = true
        
        openURLCapableDelegate.shouldOpenNextURL = true
        let launchOptions: [String : AnyObject]
        if #available(iOS 9.0, *) {
            launchOptions = [
                UIApplicationLaunchOptionsURLKey : url,
                UIApplicationLaunchOptionsSourceApplicationKey : sourceBundleID,
                UIApplicationLaunchOptionsAnnotationKey : annotation,
                UIApplicationOpenURLOptionsOpenInPlaceKey : copyBeforeUse
            ]
        } else {
            launchOptions = [
                UIApplicationLaunchOptionsURLKey : url,
                UIApplicationLaunchOptionsSourceApplicationKey : sourceBundleID,
                UIApplicationLaunchOptionsAnnotationKey : annotation
            ]
        }
        
        XCTAssertTrue(openURLCapableDelegate.application(UIApplication.sharedApplication(), willFinishLaunchingWithOptions: launchOptions))
        XCTAssertTrue(openURLCapableDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: launchOptions))
        
        switch openURLCapableDelegate.launchItem {
        case .OpenURLItem:
            break
        default:
            XCTFail()
        }
        
        XCTAssertNotNil(openURLCapableDelegate.handledURLToOpen)
        openURLCapableDelegate.handledURLToOpen = nil
        
        let otherUrl = NSURL(string: "cash.me/$martin")!
        if #available(iOS 9.0, *) {
            XCTAssertTrue(openURLCapableDelegate.application(UIApplication.sharedApplication(), openURL: otherUrl, options: [:]))
        } else {
            XCTAssertTrue(openURLCapableDelegate.application(UIApplication.sharedApplication(), openURL: otherUrl, sourceApplication: sourceBundleID, annotation: annotation))
        }
        
        XCTAssertEqual(openURLCapableDelegate.handledURLToOpen?.url, otherUrl)
    }
}


// MARK: - OpenURLCapableDelegate


class OpenURLCapableDelegate: AppLaunchedDelegate, OpenURLCapable {
    var shouldOpenNextURL = true
    var handledURLToOpen: URLToOpen?
    
    func handleURLToOpen(urlToOpen: URLToOpen) -> Bool {
        handledURLToOpen = urlToOpen
        return shouldOpenNextURL
    }
    
    func canOpenLaunchURL(launchURLToOpen: URLToOpen) -> Bool {
        handledURLToOpen = launchURLToOpen
        return shouldOpenNextURL
    }
}
