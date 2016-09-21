//
//  SuperDelegateTests.swift
//  SuperDelegateTests
//
//  Created by Dan Federman on 4/13/16.
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


class SuperDelegateTests: XCTestCase {
    
    // MARK: - Behavioral Tests
    
    
    // MARK: NonConformingTestDelegate Tests
    
    
    func test_willFinishLaunchingWithOptions_notesImproperAPIUsage() {
        let nonConformingTestDelegate = NonConformingTestDelegate()
        nonConformingTestDelegate.expectImproperAPIUsage = true
        XCTAssertFalse(nonConformingTestDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: nil))
        XCTAssertFalse(nonConformingTestDelegate.expectImproperAPIUsage)
    }
    
    func test_didFinishLaunchingWithOptions_notesImproperAPIUsage() {
        let nonConformingTestDelegate = NonConformingTestDelegate()
        nonConformingTestDelegate.expectImproperAPIUsage = true
        XCTAssertFalse(nonConformingTestDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: nil))
        XCTAssertFalse(nonConformingTestDelegate.expectImproperAPIUsage)
    }
    
    func test_setupApplicationOnce_notesImproperAPIUsageAndGuardsAgainstCallingSetupApplication() {
        let nonConformingTestDelegate = NonConformingTestDelegate()
        nonConformingTestDelegate.expectImproperAPIUsage = true
        nonConformingTestDelegate.setupApplicationOnce()
        XCTAssertFalse(nonConformingTestDelegate.expectImproperAPIUsage)
        XCTAssertFalse(nonConformingTestDelegate.applicationHasBeenSetUp)
    }
    
    func test_loadInterfaceOnce_notesImproperAPIUsageAndGuardsAgainstLoadingInterface() {
        let nonConformingTestDelegate = NonConformingTestDelegate()
        nonConformingTestDelegate.expectImproperAPIUsage = true
        nonConformingTestDelegate.loadInterfaceOnce(with: .none)
        XCTAssertFalse(nonConformingTestDelegate.expectImproperAPIUsage)
        XCTAssertFalse(nonConformingTestDelegate.interfaceLoaded)
    }
    
    
    // MARK: AppLaunchedDelegate Tests
    
    
    func test_setupApplicationOnce_setsUpApplicationOnce() {
        let appLaunchedDelegate = AppLaunchedDelegate()
        XCTAssertFalse(appLaunchedDelegate.applicationHasBeenSetUp)
        appLaunchedDelegate.setupApplicationOnce()
        XCTAssertTrue(appLaunchedDelegate.applicationHasBeenSetUp)
        appLaunchedDelegate.setupApplicationOnce()
    }
    
    func test_loadInterfaceOnce_loadsInterfaceOnce() {
        let appLaunchedDelegate = AppLaunchedDelegate()
        XCTAssertFalse(appLaunchedDelegate.interfaceLoaded)
        appLaunchedDelegate.loadInterfaceOnce(with: .none)
        XCTAssertTrue(appLaunchedDelegate.interfaceLoaded)
        appLaunchedDelegate.loadInterfaceOnce(with: .none)
    }
    
    func test_applicationWillFinishLaunching_notesImproperAPIUsageAndReturnsFalseWhenUnsupportedLaunchOptionUserActivityPresent() {
        let appLaunchedDelegate = AppLaunchedDelegate()
        appLaunchedDelegate.expectImproperAPIUsage = true
        // Must return false to signal that the URL user activity could not be handled.
        XCTAssertFalse(appLaunchedDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: [UIApplicationLaunchOptionsKey.userActivityDictionary : [UIApplicationLaunchOptionsKey.userActivity : NSUserActivity(activityType: "a type")]]))
        XCTAssertFalse(appLaunchedDelegate.expectImproperAPIUsage)
        XCTAssertEqual(appLaunchedDelegate.launchItem, LaunchItem.none)
    }
    
    @available(iOS 9.0, *)
    func test_applicationWillFinishLaunching_notesImproperAPIUsageAndReturnsTrueWhenUnsupportedLaunchOptionShortcutItemPresent() {
        let appLaunchedDelegate = AppLaunchedDelegate()
        appLaunchedDelegate.expectImproperAPIUsage = true
        // Must return true to signal that the shortcut wasn't handled.
        XCTAssertTrue(appLaunchedDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: [UIApplicationLaunchOptionsKey.shortcutItem : UIApplicationShortcutItem(type: "A type", localizedTitle: "A title")]))
        XCTAssertFalse(appLaunchedDelegate.expectImproperAPIUsage)
        XCTAssertEqual(appLaunchedDelegate.launchItem, LaunchItem.none)
    }
    
    func test_applicationWillFinishLaunching_notesImproperAPIUsageAndReturnsFalseWhenUnsupportedLaunchOptionURLPresent() {
        let appLaunchedDelegate = AppLaunchedDelegate()
        appLaunchedDelegate.expectImproperAPIUsage = true
        // Must return false to signal that the URL can not be handled.
        XCTAssertFalse(appLaunchedDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: [UIApplicationLaunchOptionsKey.url : URL(fileURLWithPath: "/")]))
        XCTAssertFalse(appLaunchedDelegate.expectImproperAPIUsage)
        XCTAssertEqual(appLaunchedDelegate.launchItem, LaunchItem.none)
    }
    
    func test_setupMainWindow_notesImproperAPIUsageWhenCalledOutsideOfLoadInterfaceWithLaunchItem() {
        let appLaunchedDelegate = AppLaunchedDelegate()
        appLaunchedDelegate.expectImproperAPIUsage = true
        
        appLaunchedDelegate.setup(mainWindow: UIWindow())
        XCTAssertFalse(appLaunchedDelegate.expectImproperAPIUsage)
    }
}


// MARK: - NonConformingTestDelegate


class NonConformingTestDelegate: SuperDelegate {
    
    deinit {
        // Reset all data when our subclasses go out of scope.
        testing_resetAllData()
    }
    
    var expectImproperAPIUsage = false
    
    override func noteImproperAPIUsage(_ text: String) {
        XCTAssertTrue(expectImproperAPIUsage)
        
        expectImproperAPIUsage = false
    }
}


// MARK: - AppLaunchedDelegate


class AppLaunchedDelegate: NonConformingTestDelegate, ApplicationLaunched {
    
    var hasSetupApplication = false
    func setupApplication() {
        XCTAssertFalse(hasSetupApplication)
        hasSetupApplication = true
    }
    
    var hasLoadedApplication = false
    var launchItem = LaunchItem.none
    func loadInterface(launchItem: LaunchItem) {
        XCTAssertFalse(hasLoadedApplication)
        hasLoadedApplication = true
        
        self.launchItem = launchItem
    }
}
