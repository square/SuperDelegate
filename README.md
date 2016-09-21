# SuperDelegate

[![CI Status](https://travis-ci.org/square/SuperDelegate.svg?branch=master)](https://travis-ci.org/square/SuperDelegate)
[![Carthage Compatibility](https://img.shields.io/badge/carthage-✓-e2c245.svg)](https://github.com/Carthage/Carthage/)
[![Version](https://img.shields.io/cocoapods/v/SuperDelegate.svg)](http://cocoadocs.org/docsets/SuperDelegate)
[![License](https://img.shields.io/cocoapods/l/SuperDelegate.svg)](http://cocoadocs.org/docsets/SuperDelegate)
[![Platform](https://img.shields.io/cocoapods/p/SuperDelegate.svg)](http://cocoadocs.org/docsets/SuperDelegate)

SuperDelegate provides a consistent App Delegate API across all iOS SDKs while protecting you from bugs in the application lifecycle.

## Purpose

**Consolidate tribal knowledge about and workarounds for eccentricities in the UIApplicationDelegate API contract.**

Example: in iOS 8.4, `application(_:handleWatchKitExtensionRequest:reply:)` is called before `application(_:didFinishLaunchingWithOptions:)`; this is not the case in iOS 8.0-8.3. SuperDelegate protects you against such changes in the API contract.

**Create a clean UIApplicationDelegate API that meets your needs.**

Example: `application(_:didFinishLaunchingWithOptions:)` and `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)` will tell you when you receive a push notification (sometimes they tell you twice!), but they don't differentiate between delivery due to a customer tapping on notification or delivery due to the `content-available=1` flag being set in the APNS dictionary. SuperDelegate is designed to give you the information you need when you need it.

## Installation

### CocoaPods

To install SuperDelegate in your iOS project running Xcode 7 with [CocoaPods](http://cocoapods.org), add the following to your `Podfile`:

```
platform :ios, '8.0'
pod 'SuperDelegate', '~> 0.8.0'
```

Xcode 8 and Swift 3 projects should use 0.9.0

### Carthage

To install SuperDelegate in your iOS project with [Carthage](https://github.com/Carthage/Carthage), add the following to your `Cartfile`:

```ogdl
github "Square/SuperDelegate"
```

Run `carthage` to build the framework and drag the built `SuperDelegate.framework` into your Xcode project.

### Swift Package Manager

To install SuperDelegate in your iOS project with [Swift Package Manager](https://github.com/apple/swift-package-manager), the following definition can be added to the dependencies of your `Project`:

```swift
  .Package(
    url: "https://github.com/square/SuperDelegate.git",
    versions: Version(0,8,0)..<Version(0,9,0)
  ),
```

### Submodules

To use git submodules, checkout the submodule with `git submodule add git@github.com:Square/SuperDelegate.git`, drag SuperDelegate.xcodeproj to your project, and add SuperDelegate as a build dependency.

## Getting Started

```swift
public class AppDelegate: SuperDelegate, ApplicationLaunched
```

Have your `UIApplicationDelegate` subclass `SuperDelegate` and conform to the `ApplicationLaunched` protocol. SuperDelegate guarantees to call `setupApplication()` only once per application launch, before making any other delegate calls. SuperDelegate also guarantees that `loadInterfaceWithLaunchItem(_:)` will be called once, when your app is brought to the foreground for the first time after it is launched.


## Adopting more AppDelegate features

To opt into more AppDelegate features, have your `AppDelegate` class conform to the associated protocol. For example, making your `AppDelegate` class conform to `LocalNotificationCapable` will give your app the ability to post local notifications.


## Requirements

* Xcode 7.0 or later.
* iOS 8 or later.

## Versions
* 0.8.* – Swift 2.3 and Xcode 7.3+. This version has been thouroughly vetted.
* 0.9.* – Swift 3.0 and Xcode 8+.
* 1.0 – Swift 3.0, Xcode 8+, and iOS 10 SDK adoption.

## Contributing

We’re glad you’re interested in SuperDelegate, and we’d love to see where you take it. Please read our [contributing guidelines](Contributing.md) prior to submitting a Pull Request.

Thanks, and happy delegating!
