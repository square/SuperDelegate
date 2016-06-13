//
//  SuperDelegate.swift
//  SuperDelegate
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

import Foundation


// MARK: ApplicationLaunched – SuperDelegate subclass must extend ApplicationLaunched.


public protocol ApplicationLaunched {
    /// Very first method that SuperDelegate calls on launch. Guaranteed to only be called once.
    func setupApplication()
    /// Called when the app launches. Guaranteed to only be called once.
    func loadInterface(launchItem: LaunchItem)
}


// MARK: - SuperDelegate


open class SuperDelegate: NSObject, UIApplicationDelegate {
    
    
    // MARK: Public Properties
    
    
    public internal(set) var applicationIsInForeground = false
    
    
    // MARK: Public Methods
    
    
    private var withinLoadInterface = false
    /// Convenience method to set up the main window. Must be called from loadInterface(launchItem:).
    public func setup(mainWindow: UIWindow) {
        guard withinLoadInterface else {
            noteImproperAPIUsage("Must call \(#function) from within loadInterface(launchItem:)")
            return
        }
        
        mainWindow.frame = UIScreen.main.bounds
        mainWindow.makeKeyAndVisible()
    }
    
    
    // MARK: - UIApplicationDelegate
    
    
    private var handledShortcutInWillFinishLaunching = false
    private var couldHandleURLInWillFinishLaunching = true
    private var couldHandleUserActivityInWillFinishLaunching = true
    
    final public func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        guard self is ApplicationLaunched else {
            noteImproperAPIUsage("\(self) must conform to ApplicationLaunched protocol")
            return false
        }
        
        setupApplicationOnce()
        requestUserNotificationPermissionsIfPreviouslyRegistered()
        
        // Use notification listeners to respond to application lifecycle events to subclasses can override the default hooks.
        applicationDidBecomeActiveListener = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: application, queue: OperationQueue.main) { [weak self] _ in
            self?.applicationIsInForeground = true
        }
        applicationDidEnterBackgroundListener = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: application, queue: OperationQueue.main) { [weak self] _ in
            self?.applicationIsInForeground = false
        }
        
        var launchItem = LaunchItem(launchOptions: launchOptions)
        switch launchItem {
        case let .shortcut(launchShortcutItem):
            if #available(iOS 9.0, *) {
                guard let shortcutCapableSelf = self as? ShortcutCapable else {
                    noteImproperAPIUsage("Received shortcut item but \(self) does not conform to ShortcutCapable. Not handling shortcut.")
                    return true
                }
                
                handledShortcutInWillFinishLaunching = shortcutCapableSelf.canHandle(shortcutItem: launchShortcutItem)
                if !handledShortcutInWillFinishLaunching {
                    launchItem = .none
                }
            } else {
                // Should not be possible.
                noteImproperAPIUsage("Launched due to ShortcutItem but not running iOS 9 or later.")
                launchItem = .none
            }
            
        case let .userActivity(launchUserActivity):
            guard let userActivityCapableSelf = self as? UserActivityCapable else {
                noteImproperAPIUsage("Received user activity item but \(self) does not conform to UserActivityCapable. Not handling user activity.")
                return false
            }
            
            couldHandleUserActivityInWillFinishLaunching = userActivityCapableSelf.canResume(userActivity: launchUserActivity)
            if !couldHandleUserActivityInWillFinishLaunching {
                launchItem = .none
            }
            
        case let .openURL(launchURLToOpen):
            guard let openURLCapableSelf = self as? OpenURLCapable else {
                noteImproperAPIUsage("Received openURL action but \(self) does not conform to OpenURLCapable. Not handling URL.")
                return false
            }
            
            couldHandleURLInWillFinishLaunching = openURLCapableSelf.canOpen(launchURL: launchURLToOpen)
            if !couldHandleURLInWillFinishLaunching {
                launchItem = .none
            }
            
        case .remoteNotification, .localNotification, .none:
            // Nothing to do.
            break
        }
        
        
        if self is StateRestorationCapable {
            // Per Apple's docs: If your app relies on the state restoration machinery to restore its view controllers, always show your app’s window from this method. Do not show the window in your app’s application:didFinishLaunchingWithOptions: method. Calling the window’s makeKeyAndVisible method does not make the window visible right away anyway. UIKit waits until your app’s application:didFinishLaunchingWithOptions: method finishes before making the window visible on the screen.
            
            loadInterfaceOnce(with: launchItem)
        }
        
        return true
            // Signal to iOS if we can not handle the opened URL
            && couldHandleURLInWillFinishLaunching
            // Signal to iOS if we could handle the user activity type
            && couldHandleUserActivityInWillFinishLaunching
            // While counterintuitive, we must return false if we have handled a shortcut action. Per Apple's docs: If you find that your app was indeed launched using a quick action, perform the requested quick action within the launch method and return a value of false from that method. When you return a value of false, the system does not call the application:performActionForShortcutItem:completionHandler: method.
            && !handledShortcutInWillFinishLaunching
    }
    
    final public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        guard self is ApplicationLaunched else {
            noteImproperAPIUsage("\(self) must conform to ApplicationLaunched protocol")
            return false
        }
        
        if self is RemoteNotificationCapable {
            application.registerForRemoteNotifications()
        }
        
        if let launchBluetoothPeripheralIdentifiers = launchOptions?[UIApplicationLaunchOptionsKey.bluetoothPeripherals] as? [String] {
            guard let backgroundBluetoothPeripheralCapableSelf = self as? BackgroundBluetoothPeripheralCapable else {
                noteImproperAPIUsage("Received background bluetooth peripheral restore identifier but \(self) does not conform to BackgroundBluetoothPeripheralCapable. Failing to launch app.")
                return false
            }
            
            backgroundBluetoothPeripheralCapableSelf.restoreBluetoothPeripheralManagers(withIdentifiers: launchBluetoothPeripheralIdentifiers)
        }
        
        if let launchBluetoothCentralIdentifiers = launchOptions?[UIApplicationLaunchOptionsKey.bluetoothCentrals] as? [String] {
            guard let backgroundBluetoothCentralCapableSelf = self as? BackgroundBluetoothCentralCapable else {
                noteImproperAPIUsage("Received background bluetooth peripheral restore identifier but \(self) does not conform to BackgroundBluetoothCentralCapable. Failing to launch app.")
                return false
            }
            
            backgroundBluetoothCentralCapableSelf.restoreBluetoothCentralManagers(withIdentifiers: launchBluetoothCentralIdentifiers)
        }
        
        if let launchDueToLocationEvent = launchOptions?[UIApplicationLaunchOptionsKey.location] as? Bool, launchDueToLocationEvent {
            guard let locationEventCapableSelf = self as? LocationEventCapable else {
                noteImproperAPIUsage("Launched due to location event but \(self) does not conform to LocationEventCapable. Failing to launch app.")
                return false
            }
            
            locationEventCapableSelf.applicationLaunchedDueToLocationEvent()
        }
        
        var launchItem = LaunchItem(launchOptions: launchOptions)
        switch launchItem {
        case .shortcut:
            if !handledShortcutInWillFinishLaunching {
                launchItem = .none
            }
            
        case let .userActivity(item):
            if couldHandleUserActivityInWillFinishLaunching {
                launchOptionsUserActivity = item
            } else {
                launchItem = .none
            }
            
        case let .openURL(item):
            if couldHandleURLInWillFinishLaunching {
                launchOptionsURLToOpen = item.url
            } else {
                launchItem = .none
            }
            
        case let .remoteNotification(item):
            launchOptionsRemoteNotification = item
            
        case let .localNotification(item):
            launchOptionsLocalNotification = item
            
        case .none:
            // Nothing to do.
            break
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(5), execute: {
            self.launchOptionsUserActivity = nil
            self.launchOptionsURLToOpen = nil
            self.launchOptionsRemoteNotification = nil
            self.launchOptionsLocalNotification = nil
        })
        
        loadInterfaceOnce(with: launchItem)
        
        // Now that we've loaded the interface with our launch item, set up our willEnterForegroundListener
        applicationWillEnterForegroundListener = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: application, queue: OperationQueue.main) { [weak self] _ in
            guard let weakSelf = self else {
                return
            }
            
            do {
                // Clear our launchOption* ivars that prevent handling a possible LaunchItem twice. WillEnterForeground is invoked before the app delegate handlers for LaunchItems are invoked if the app is brought to the foreground due to interaction with the LaunchItem. Moreover, WillEnterForeground is not invoked when the application is in the .Inactive state during didFinishLaunching: – WillEnterForeground is invoked only after the app is brought to the foreground after didFinishLaunching: in the .Background state, or when the app is brought to the foreground after DidEnterBackground. Therefore, any LaunchItems we receive after WillEnterForeground are not duplicates and must be processed.
                weakSelf.launchOptionsUserActivity = nil
                weakSelf.launchOptionsURLToOpen = nil
                weakSelf.launchOptionsRemoteNotification = nil
                weakSelf.launchOptionsLocalNotification = nil;
            }
            
            // Register for user notifications again just in case the customer has changed their notification settings on us.
            weakSelf.requestUserNotificationPermissionsIfPreviouslyRegistered()
        }
        
        return true
            // Signal to iOS if we can not handle the opened URL
            && couldHandleURLInWillFinishLaunching
            // Signal to iOS if we could handle the user activity type
            && couldHandleUserActivityInWillFinishLaunching
    }
    
    
    // MARK: Internal Properties
    
    
    /// iOS 8 and 9 deliver the same remote notification via launchOptions and then via application(_:didReceiveRemoteNotification:fetchCompletionHandler:). Protect against processing twice by storing the launchOptionsRemoteNotification, and not processing notifications that are equal to it immediately after launch.
    var launchOptionsRemoteNotification: RemoteNotification?
    
    /// iOS 8 and 9 deliver the same local notification via launchOptions and then via application(_:didReceive:). Protect against processing twice by storing the launchOptionsLocalNotification, and not processing notifications that are equal to it immediately after launch.
    var launchOptionsLocalNotification: UILocalNotification?
    
    /// iOS 8 and 9 deliver the same URL via launchOptions and then via application(_:open:*:). Protect against processing twice by storing the launchOptionsURLToOpen, and not processing URLs that are equal to it immediately after launch.
    var launchOptionsURLToOpen: URL?
    
    /// iOS 8 and 9 deliver the same URL via launchOptions and then via application(_:continue:restorationHandler:). Protect against processing twice by storing the launchOptionsUserActivity, and not processing user activity items that are equal to it immediately after launch.
    var launchOptionsUserActivity: NSUserActivity?
    
    
    // MARK: Internal Methods
    
    
    func noteImproperAPIUsage(_ text: String) {
        assertionFailure("Improper SuperDelegate API Usage: \(text)")
    }
    
    
    var applicationHasBeenSetUp = false
    final func setupApplicationOnce() {
        guard !applicationHasBeenSetUp else {
            // We've already setup the application. Ignore.
            return
        }
        
        guard let applicationLaunchedCapableSelf = self as? ApplicationLaunched else {
            noteImproperAPIUsage("\(self) must conform to ApplicationLaunched protocol")
            return
        }
        
        applicationLaunchedCapableSelf.setupApplication()
        applicationHasBeenSetUp = true
    }
    
    var interfaceLoaded = false
    func loadInterfaceOnce(with launchItem: LaunchItem) {
        // iOS 8.0 introduced a bug (fixed in 8.3) where loading UI on a 32bit device while the app is in the .Background state can cause a crash due to CUIShapeEffectStack.sharedCIContext() trying to access the GPU when created outside of application(_:applicationDidFinishLaunching:options:). Hack around the problem by creating a sharedCIContext within application(_:application*FinishLaunching:options:) by creating a dummy navigation bar and laying it out. For more details, see https://devforums.apple.com/thread/246744
        UINavigationBar(frame: CGRect(x: 0, y: 0, width: 1, height: 1)).layoutSubviews()
        
        guard !interfaceLoaded else {
            // We've already loaded the interface. Ignore.
            return
        }
        
        guard let applicationLaunchedSelf = self as? ApplicationLaunched else {
            noteImproperAPIUsage("\(self) must conform to ApplicationLaunched protocol")
            return
        }
        withinLoadInterface = true
        applicationLaunchedSelf.loadInterface(launchItem: launchItem)
        withinLoadInterface = false
        
        interfaceLoaded = true
    }
    
    
    // MARK: Private Properties
    
    
    private var applicationDidBecomeActiveListener: NSObjectProtocol?
    private var applicationWillEnterForegroundListener: NSObjectProtocol?
    private var applicationDidEnterBackgroundListener: NSObjectProtocol?
    
    
    // MARK: Private Methods
    
    
    func requestUserNotificationPermissionsIfPreviouslyRegistered() {
        if self is UserNotificationCapable && previouslyRequestedUserNotificationPermissions {
            requestUserNotificationPermissions()
        }
    }
    
    
    // MARK: Test helpers
    
    
    func testing_resetAllData() {
        if self is UserNotificationCapable {
            previouslyRequestedUserNotificationPermissions = false
        }
        
        if let applicationDidBecomeActiveListener = applicationDidBecomeActiveListener {
            NotificationCenter.default.removeObserver(applicationDidBecomeActiveListener)
        }
        if let applicationWillEnterForegroundListener = applicationWillEnterForegroundListener {
            NotificationCenter.default.removeObserver(applicationWillEnterForegroundListener)
        }
        if let applicationDidEnterBackgroundListener = applicationDidEnterBackgroundListener {
            NotificationCenter.default.removeObserver(applicationDidEnterBackgroundListener)
        }
    }
}
