//
//  SuperDelegate+StateRestorationTests.swift
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


class SuperDelegateStateRestorationTests: SuperDelegateTests {
    
    
    // MARK: - Behavioral Tests
    
    
    func test_applicationWillFinishLaunching_loadsInterface() {
        let stateRestorationCapableDelegate = StateRestorationCapableDelegate()
        XCTAssertTrue(stateRestorationCapableDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: nil))
        XCTAssertTrue(stateRestorationCapableDelegate.interfaceLoaded)
        
        switch stateRestorationCapableDelegate.launchItem {
        case .none:
            break
        default:
            XCTFail()
        }
        
        XCTAssertTrue(stateRestorationCapableDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: nil))
    }
}


// MARK: - StateRestorationCapableDelegate


class StateRestorationCapableDelegate: AppLaunchedDelegate, StateRestorationCapable {
    
    func shouldSaveApplicationState(using coder: NSCoder) -> Bool {
        // Nothing to test here. This method is just a passthrough.
        return true
    }
    
    func shouldRestoreApplicationState(using coder: NSCoder) -> Bool {
        // Nothing to test here. This method is just a passthrough.
        return true
    }
    
    func willEncodeRestorableState(using coder: NSCoder) {
        // Nothing to test here. This method is just a passthrough.
    }
    
    func didDecodeRestorableState(using coder: NSCoder) {
        // Nothing to test here. This method is just a passthrough.
    }
    
    func viewControllerWithRestorationIdentifierPath(identifierComponents: [Any], coder: NSCoder) -> UIViewController? {
        // Nothing to test here. This method is just a passthrough.
        return nil;
    }
}
