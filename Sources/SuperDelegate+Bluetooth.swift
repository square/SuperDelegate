//
//  SuperDelegate+Bluetooth.swift
//  SuperDelegate
//
//  Created by Dan Federman on 4/17/16.
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

import Foundation


// MARK: BackgroundBluetoothPeripheralCapable – Opting into this protocol gives your app the ability to handle background bluetooth peripheral events.


public protocol BackgroundBluetoothPeripheralCapable: ApplicationLaunched {
    /// Called when the application is launched due to background bluetooth peripheral activity.
    func restoreBluetoothPeripheralManagers(withIdentifiers identifiers: [String])
}


// MARK: BackgroundBluetoothCentralCapable – Opting into this protocol gives your app the ability to handle background bluetooth central events.


public protocol BackgroundBluetoothCentralCapable: ApplicationLaunched {
    /// Called when the application is launched due to background bluetooth central activity.
    func restoreBluetoothCentralManagers(withIdentifiers identifiers: [String])
}
