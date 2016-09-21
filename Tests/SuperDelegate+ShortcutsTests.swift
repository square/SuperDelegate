//
//  SuperDelegate+ShortcutsTests.swift
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


@available(iOS 9.0, *)
class SuperDelegateShortcutsTests: SuperDelegateTests {
    
    
    // MARK: - Behavioral Tests
    
    
    func test_applicationDidFinishLaunching_doesNotLoadInterfaceWithShortcutItemIfCanHandleShortcutItemFails() {
        let shortcutCapableDelegate = ShortcutsCapableDelegate()
        let shortcutItem = UIApplicationShortcutItem(type: "a shortcut type", localizedTitle: "the best shortcut title")
        
        shortcutCapableDelegate.shouldHandleNextShortcut = false
        let launchOptions = [
            UIApplicationLaunchOptionsKey.shortcutItem : shortcutItem,
            ]
        
        XCTAssertTrue(shortcutCapableDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: launchOptions))
        XCTAssertTrue(shortcutCapableDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: launchOptions))
        
        switch shortcutCapableDelegate.launchItem {
        case .none:
            break
        default:
            XCTFail()
        }
    }
    
    func test_performActionFor_doesNotCallHandleShortcutItemToOpenIfCanHandleShortcutItemFails() {
        let shortcutCapableDelegate = ShortcutsCapableDelegate()
        let shortcutItem = UIApplicationShortcutItem(type: "a shortcut type", localizedTitle: "the best shortcut title")
        
        shortcutCapableDelegate.shouldHandleNextShortcut = false
        shortcutCapableDelegate.application(UIApplication.shared, performActionFor: shortcutItem) { (handledShortcutItem) in
            XCTAssertFalse(handledShortcutItem)
        }
        
        XCTAssertNil(shortcutCapableDelegate.handledShortcut)
    }
    
    func test_applicationDidFinishLaunching_loadsInterfaceWithShortcutItemIfCanHandleShortcutItemSucceeds() {
        let shortcutCapableDelegate = ShortcutsCapableDelegate()
        let shortcutItem = UIApplicationShortcutItem(type: "a shortcut type", localizedTitle: "the best shortcut title")
        
        let launchOptions = [
            UIApplicationLaunchOptionsKey.shortcutItem : shortcutItem,
            ]
        
        XCTAssertFalse(shortcutCapableDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: launchOptions))
        XCTAssertTrue(shortcutCapableDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: launchOptions))
        
        switch shortcutCapableDelegate.launchItem {
        case let .shortcut(launchShortcutItem):
            XCTAssertEqual(shortcutItem, launchShortcutItem)
        default:
            XCTFail()
        }
    }
    
    func test_performActionFor_callsHandleShortcutItemToOpenIfCanHandleShortcutItemSucceeds() {
        let shortcutCapableDelegate = ShortcutsCapableDelegate()
        let shortcutItem = UIApplicationShortcutItem(type: "a shortcut type", localizedTitle: "the best shortcut title")
        
        shortcutCapableDelegate.loadInterfaceOnce(with: .none)
        shortcutCapableDelegate.application(UIApplication.shared, performActionFor: shortcutItem) { (handledShortcutItem) in
            XCTAssertTrue(handledShortcutItem)
        }
        
        XCTAssertEqual(shortcutItem, shortcutCapableDelegate.handledShortcut)
    }
}


// MARK: - ShortcutsCapableDelegate


@available(iOS 9.0, *)
class ShortcutsCapableDelegate: AppLaunchedDelegate, ShortcutCapable {
    
    var shouldHandleNextShortcut = true
    func canHandle(shortcutItem: UIApplicationShortcutItem) -> Bool {
        return shouldHandleNextShortcut
    }
    
    var handledShortcut: UIApplicationShortcutItem?
    func handle(shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping () -> Swift.Void) {
        handledShortcut = shortcutItem
        completionHandler()
    }
}
