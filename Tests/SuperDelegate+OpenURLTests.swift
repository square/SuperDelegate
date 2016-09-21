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
        let url = URL(string: "cash.me/$dan")!
        let sourceBundleID = "com.squareup.cash"
        let annotation = 1
        let copyBeforeUse = true
        
        openURLCapableDelegate.shouldOpenNextURL = false
        let launchOptions: [UIApplicationLaunchOptionsKey : Any]
        if #available(iOS 9.0, *) {
            launchOptions = [
                UIApplicationLaunchOptionsKey.url : url,
                UIApplicationLaunchOptionsKey.sourceApplication : sourceBundleID,
                UIApplicationLaunchOptionsKey.annotation : annotation,
                UIApplicationLaunchOptionsKey.openInPlace : copyBeforeUse
            ]
        } else {
            launchOptions = [
                UIApplicationLaunchOptionsKey.url : url,
                UIApplicationLaunchOptionsKey.sourceApplication : sourceBundleID,
                UIApplicationLaunchOptionsKey.annotation : annotation
            ]
        }
        
        XCTAssertFalse(openURLCapableDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: launchOptions))
        XCTAssertFalse(openURLCapableDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: launchOptions))
        
        switch openURLCapableDelegate.launchItem {
        case .none:
            break
        default:
            XCTFail()
        }
    }
    
    func test_applicationDidFinishLaunching_passesThroughOptions() {
        let openURLCapableDelegate = OpenURLCapableDelegate()
        let url = URL(string: "cash.me/$dan")!
        let sourceBundleID = "com.squareup.cash"
        let annotation = 1
        let copyBeforeUse = true
        
        if #available(iOS 9.0, *) {
            XCTAssertTrue(
                openURLCapableDelegate.application(UIApplication.shared,
                                                   didFinishLaunchingWithOptions: [
                                                    UIApplicationLaunchOptionsKey.url : url,
                                                    UIApplicationLaunchOptionsKey.sourceApplication : sourceBundleID,
                                                    UIApplicationLaunchOptionsKey.annotation : annotation,
                                                    UIApplicationLaunchOptionsKey.openInPlace : copyBeforeUse
                    ]
                )
            )
        } else {
            XCTAssertTrue(
                openURLCapableDelegate.application(UIApplication.shared,
                                                   didFinishLaunchingWithOptions: [
                                                    UIApplicationLaunchOptionsKey.url : url,
                                                    UIApplicationLaunchOptionsKey.sourceApplication : sourceBundleID,
                                                    UIApplicationLaunchOptionsKey.annotation : annotation
                    ]
                )
            )
        }
        
        switch openURLCapableDelegate.launchItem {
        case let .openURL(item):
            XCTAssertEqual(item.url, url)
            XCTAssertEqual(item.sourceApplicationBundleID, sourceBundleID)
            XCTAssertEqual(item.annotation as? Int, annotation)
            XCTAssertEqual(item.copyBeforeUse, copyBeforeUse)
        default:
            XCTFail()
        }
    }
    
    func test_openURL_options_passesThroughOptions() {
        let openURLCapableDelegate = OpenURLCapableDelegate()
        openURLCapableDelegate.loadInterfaceOnce(with: .none)
        
        let url = URL(string: "cash.me/$dan")!
        let sourceBundleID = "com.squareup.cash"
        let annotation = 1
        let copyBeforeUse = true
        
        if #available(iOS 9.0, *) {
            XCTAssertTrue(
                openURLCapableDelegate.application(UIApplication.shared,
                                                   open: url,
                                                   options: [
                                                    UIApplicationOpenURLOptionsKey.sourceApplication : sourceBundleID,
                                                    UIApplicationOpenURLOptionsKey.annotation : annotation,
                                                    UIApplicationOpenURLOptionsKey.openInPlace : copyBeforeUse
                    ]
                )
            )
            
        } else {
            XCTAssertTrue(openURLCapableDelegate.application(UIApplication.shared, open: url, sourceApplication: sourceBundleID, annotation: annotation))
        }
        
        XCTAssertEqual(openURLCapableDelegate.handledURLToOpen?.url, url)
        XCTAssertEqual(openURLCapableDelegate.handledURLToOpen?.sourceApplicationBundleID, sourceBundleID)
        XCTAssertEqual(openURLCapableDelegate.handledURLToOpen?.annotation as? Int, annotation)
        XCTAssertEqual(openURLCapableDelegate.handledURLToOpen?.copyBeforeUse, copyBeforeUse)
    }
    
    func test_openURL_sourceApplication_annotation_passesThroughOptions() {
        let openURLCapableDelegate = OpenURLCapableDelegate()
        openURLCapableDelegate.loadInterfaceOnce(with: .none)
        
        let url = URL(string: "cash.me/$dan")!
        let sourceBundleID = "com.squareup.cash"
        let annotation = 1
        
        XCTAssertTrue(openURLCapableDelegate.application(UIApplication.shared, open: url, sourceApplication: sourceBundleID, annotation: annotation))
        
        XCTAssertEqual(openURLCapableDelegate.handledURLToOpen?.url, url)
        XCTAssertEqual(openURLCapableDelegate.handledURLToOpen?.sourceApplicationBundleID, sourceBundleID)
        XCTAssertEqual(openURLCapableDelegate.handledURLToOpen?.annotation as? Int, annotation)
        XCTAssertFalse(openURLCapableDelegate.handledURLToOpen?.copyBeforeUse ?? true)
    }
    
    func test_openURL_dropsURLDeliveredToLoadInterfaceWithLaunchItem() {
        let openURLCapableDelegate = OpenURLCapableDelegate()
        let url = URL(string: "cash.me/$dan")!
        let sourceBundleID = "com.squareup.cash"
        let annotation = 1
        let copyBeforeUse = true
        
        openURLCapableDelegate.shouldOpenNextURL = true
        let launchOptions: [UIApplicationLaunchOptionsKey : Any]
        if #available(iOS 9.0, *) {
            launchOptions = [
                UIApplicationLaunchOptionsKey.url : url,
                UIApplicationLaunchOptionsKey.sourceApplication : sourceBundleID,
                UIApplicationLaunchOptionsKey.annotation : annotation,
                UIApplicationLaunchOptionsKey.openInPlace : copyBeforeUse
            ]
        } else {
            launchOptions = [
                UIApplicationLaunchOptionsKey.url : url,
                UIApplicationLaunchOptionsKey.sourceApplication : sourceBundleID,
                UIApplicationLaunchOptionsKey.annotation : annotation
            ]
        }
        
        XCTAssertTrue(openURLCapableDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: launchOptions))
        XCTAssertTrue(openURLCapableDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: launchOptions))
        
        switch openURLCapableDelegate.launchItem {
        case .openURL:
            break
        default:
            XCTFail()
        }
        
        XCTAssertNotNil(openURLCapableDelegate.handledURLToOpen)
        openURLCapableDelegate.handledURLToOpen = nil
        
        if #available(iOS 9.0, *) {
            XCTAssertTrue(openURLCapableDelegate.application(UIApplication.shared, open: url, options: [:]))
        } else {
            XCTAssertTrue(openURLCapableDelegate.application(UIApplication.shared, open: url, sourceApplication: sourceBundleID, annotation: annotation))
        }
        
        XCTAssertNil(openURLCapableDelegate.handledURLToOpen)
    }
    
    func test_openURL_doesNotDropURLDeliveredToLoadInterfaceWithLaunchItemAfterApplicationWillEnterForeground() {
        let openURLCapableDelegate = OpenURLCapableDelegate()
        let url = URL(string: "cash.me/$dan")!
        let sourceBundleID = "com.squareup.cash"
        let annotation = 1
        let copyBeforeUse = true
        
        openURLCapableDelegate.shouldOpenNextURL = true
        let launchOptions: [UIApplicationLaunchOptionsKey : Any]
        if #available(iOS 9.0, *) {
            launchOptions = [
                UIApplicationLaunchOptionsKey.url : url,
                UIApplicationLaunchOptionsKey.sourceApplication : sourceBundleID,
                UIApplicationLaunchOptionsKey.annotation : annotation,
                UIApplicationLaunchOptionsKey.openInPlace : copyBeforeUse
            ]
        } else {
            launchOptions = [
                UIApplicationLaunchOptionsKey.url : url,
                UIApplicationLaunchOptionsKey.sourceApplication : sourceBundleID,
                UIApplicationLaunchOptionsKey.annotation : annotation
            ]
        }
        
        XCTAssertTrue(openURLCapableDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: launchOptions))
        XCTAssertTrue(openURLCapableDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: launchOptions))
        
        switch openURLCapableDelegate.launchItem {
        case .openURL:
            break
        default:
            XCTFail()
        }
        
        XCTAssertNotNil(openURLCapableDelegate.handledURLToOpen)
        openURLCapableDelegate.handledURLToOpen = nil
        
        NotificationCenter.default.post(name: NSNotification.Name.UIApplicationWillEnterForeground, object: UIApplication.shared)
        
        if #available(iOS 9.0, *) {
            XCTAssertTrue(openURLCapableDelegate.application(UIApplication.shared, open: url, options: [:]))
        } else {
            XCTAssertTrue(openURLCapableDelegate.application(UIApplication.shared, open: url, sourceApplication: sourceBundleID, annotation: annotation))
        }
        
        XCTAssertEqual(openURLCapableDelegate.handledURLToOpen?.url, url)
    }
    
    func test_openURL_doesNotDropURLDifferentThanURLDeliveredToLoadInterfaceWithLaunchItem() {
        let openURLCapableDelegate = OpenURLCapableDelegate()
        let url = URL(string: "cash.me/$dan")!
        let sourceBundleID = "com.squareup.cash"
        let annotation = 1
        let copyBeforeUse = true
        
        openURLCapableDelegate.shouldOpenNextURL = true
        let launchOptions: [UIApplicationLaunchOptionsKey : Any]
        if #available(iOS 9.0, *) {
            launchOptions = [
                UIApplicationLaunchOptionsKey.url : url,
                UIApplicationLaunchOptionsKey.sourceApplication : sourceBundleID,
                UIApplicationLaunchOptionsKey.annotation : annotation,
                UIApplicationLaunchOptionsKey.openInPlace : copyBeforeUse
            ]
        } else {
            launchOptions = [
                UIApplicationLaunchOptionsKey.url : url,
                UIApplicationLaunchOptionsKey.sourceApplication : sourceBundleID,
                UIApplicationLaunchOptionsKey.annotation : annotation
            ]
        }
        
        XCTAssertTrue(openURLCapableDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: launchOptions))
        XCTAssertTrue(openURLCapableDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: launchOptions))
        
        switch openURLCapableDelegate.launchItem {
        case .openURL:
            break
        default:
            XCTFail()
        }
        
        XCTAssertNotNil(openURLCapableDelegate.handledURLToOpen)
        openURLCapableDelegate.handledURLToOpen = nil
        
        let otherUrl = URL(string: "cash.me/$martin")!
        if #available(iOS 9.0, *) {
            XCTAssertTrue(openURLCapableDelegate.application(UIApplication.shared, open: otherUrl, options: [:]))
        } else {
            XCTAssertTrue(openURLCapableDelegate.application(UIApplication.shared, open: otherUrl, sourceApplication: sourceBundleID, annotation: annotation))
        }
        
        XCTAssertEqual(openURLCapableDelegate.handledURLToOpen?.url, otherUrl)
    }
}


// MARK: - OpenURLCapableDelegate


class OpenURLCapableDelegate: AppLaunchedDelegate, OpenURLCapable {
    var shouldOpenNextURL = true
    var handledURLToOpen: URLToOpen?
    
    func handle(urlToOpen: URLToOpen) -> Bool {
        handledURLToOpen = urlToOpen
        return shouldOpenNextURL
    }
    
    func canOpen(launchURL: URLToOpen) -> Bool {
        handledURLToOpen = launchURL
        return shouldOpenNextURL
    }
}
