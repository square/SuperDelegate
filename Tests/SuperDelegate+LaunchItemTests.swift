//
//  SuperDelegate+LaunchItemTests.swift
//  SuperDelegate
//
//  Created by Nick Entin on 3/27/18.
//  Copyright © 2018 Square, Inc.
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


class SuperDelegateLaunchItemTests: SuperDelegateTests {
    
    func test_nilLaunchOptions() {
        let launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil
        XCTAssertEqual(LaunchItem(launchOptions: launchOptions), .none)
    }
    
    func test_emptyLaunchOptions() {
        let launchOptions: [UIApplicationLaunchOptionsKey : Any]? = [:]
        XCTAssertEqual(LaunchItem(launchOptions: launchOptions), .none)
    }
    
    func test_unknownLaunchOptions() {
        let launchOptions: [UIApplicationLaunchOptionsKey : Any] = [
            UIApplicationLaunchOptionsKey.init(rawValue: "test-key") : "test-value"
        ]
        XCTAssertEqual(LaunchItem(launchOptions: launchOptions), .unknown(launchOptions: launchOptions))
    }
    
    func test_sourceApplicationLaunchItem() {
        let launchOptions: [UIApplicationLaunchOptionsKey : Any]? = [
            UIApplicationLaunchOptionsKey.sourceApplication : "test-bundle-id"
        ]
        XCTAssertEqual(LaunchItem(launchOptions: launchOptions), .sourceApplication(bundleIdentifier: "test-bundle-id"))
    }
}
