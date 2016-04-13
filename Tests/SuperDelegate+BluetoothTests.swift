//
//  SuperDelegate+BluetoothTests.swift
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


class SuperDelegateBluetoothTests: SuperDelegateTests {
    
    
    // MARK: - Behavioral Tests
    
    
    func test_applicationDidFinishLaunching_notifiesPeripheralManagerCapableDelegateOfBluetoothPeripheralsToRestore() {
        let bluetoothPeripheralCapableDelegate = BluetoothPeripheralCapableDelegate()
        let peripheralsToRestore = ["a", "b", "c"]
        XCTAssertTrue(bluetoothPeripheralCapableDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: [UIApplicationLaunchOptionsBluetoothPeripheralsKey : peripheralsToRestore]))
        XCTAssertEqual(peripheralsToRestore, bluetoothPeripheralCapableDelegate.peripheralManagerIdentifiersToRestore)
    }
    
    
    func test_applicationDidFinishLaunching_notifiesPeripheralManagerCapableDelegateOfBluetoothCentralsToRestore() {
        let bluetoothCentralCapableDelegate = BluetoothCentralCapableDelegate()
        let centralsToRestore = ["d", "e", "f"]
        XCTAssertTrue(bluetoothCentralCapableDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: [UIApplicationLaunchOptionsBluetoothCentralsKey : centralsToRestore]))
        XCTAssertEqual(centralsToRestore, bluetoothCentralCapableDelegate.centralManagerIdentifiersToRestore)
    }
    
    
    func test_applicationDidFinishLaunching_notifiesPeripheralManagerCapableDelegateOfBluetoothPeripheralsAndCentralsToRestore() {
        let bluetoothPeripheralAndCentralCapableDelegate = BluetoothPeripheralAndCentralCapableDelegate()
        let peripheralsToRestore = ["a", "b", "c"]
        let centralsToRestore = ["d", "e", "f"]
        XCTAssertTrue(
            bluetoothPeripheralAndCentralCapableDelegate.application(UIApplication.sharedApplication(),
                didFinishLaunchingWithOptions:
                [
                    UIApplicationLaunchOptionsBluetoothPeripheralsKey : peripheralsToRestore,
                    UIApplicationLaunchOptionsBluetoothCentralsKey : centralsToRestore
                ]
            )
        )
        XCTAssertEqual(peripheralsToRestore, bluetoothPeripheralAndCentralCapableDelegate.peripheralManagerIdentifiersToRestore)
        XCTAssertEqual(centralsToRestore, bluetoothPeripheralAndCentralCapableDelegate.centralManagerIdentifiersToRestore)
    }
    
    func test_applicationWillFinishLaunching_doesNotNotifyBluetoothCapableDelegates() {
        let bluetoothPeripheralAndCentralCapableDelegate = BluetoothPeripheralAndCentralCapableDelegate()
        let peripheralsToRestore = ["a", "b", "c"]
        let centralsToRestore = ["d", "e", "f"]
        XCTAssertTrue(
            bluetoothPeripheralAndCentralCapableDelegate.application(UIApplication.sharedApplication(),
                willFinishLaunchingWithOptions:
                [
                    UIApplicationLaunchOptionsBluetoothPeripheralsKey : peripheralsToRestore,
                    UIApplicationLaunchOptionsBluetoothCentralsKey : centralsToRestore
                ]
            )
        )
        XCTAssertEqual(bluetoothPeripheralAndCentralCapableDelegate.peripheralManagerIdentifiersToRestore, [])
        XCTAssertEqual(bluetoothPeripheralAndCentralCapableDelegate.centralManagerIdentifiersToRestore, [])
    }
}


// MARK: - BluetoothPeripheralCapableDelegate


class BluetoothPeripheralCapableDelegate: AppLaunchedDelegate, BackgroundBluetoothPeripheralCapable {
    var peripheralManagerIdentifiersToRestore = [String]()
    func restoreBluetoothPeripheralManagersWithIdentifiers(peripheralManagerIdentifiersToRestore: [String]) {
        self.peripheralManagerIdentifiersToRestore = peripheralManagerIdentifiersToRestore
    }
}


// MARK: - BluetoothCentralCapableDelegate


class BluetoothCentralCapableDelegate: AppLaunchedDelegate, BackgroundBluetoothCentralCapable {
    var centralManagerIdentifiersToRestore = [String]()
    func restoreBluetoothCentralManagersWithIdentifiers(centralManagerIdentifiersToRestore: [String]) {
        self.centralManagerIdentifiersToRestore = centralManagerIdentifiersToRestore
    }
}


// MARK: - BluetoothPeripheralAndCentralCapableDelegate


class BluetoothPeripheralAndCentralCapableDelegate: AppLaunchedDelegate, BackgroundBluetoothPeripheralCapable, BackgroundBluetoothCentralCapable {
    
    var peripheralManagerIdentifiersToRestore = [String]()
    func restoreBluetoothPeripheralManagersWithIdentifiers(peripheralManagerIdentifiersToRestore: [String]) {
        self.peripheralManagerIdentifiersToRestore = peripheralManagerIdentifiersToRestore
    }
    
    var centralManagerIdentifiersToRestore = [String]()
    func restoreBluetoothCentralManagersWithIdentifiers(centralManagerIdentifiersToRestore: [String]) {
        self.centralManagerIdentifiersToRestore = centralManagerIdentifiersToRestore
    }
}
