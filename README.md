# React Native Starling

React Native Turbo Module for the Starling Protocol

## Building

In order to build the module for iOS, first build the [`starling-ios-sdk`](https://github.com/starling-protocol/starling-ios-sdk)
and place the `Starling.framework` and `StarlingProtocol.framework` artifacts in the `./Frameworks/` directory.

For Android, first build the [`starling-android-sdk`](https://github.com/starling-protocol/starling-android-sdk)
and place the `starling-release.aar` and `starling-debug.aar` artifacts in the `./android/starling/` directory.
Next, place the Gomobile `starling-protocol.aar` library in the `./android/protocol/` directory.
