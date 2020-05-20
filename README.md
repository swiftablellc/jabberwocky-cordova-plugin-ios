# Jabberwocky Head Tracking Cordova Plugin for iOS
![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/swiftablellc/jabberwocky-cordova-plugin-ios?label=release&sort=semver) ![Platform](https://img.shields.io/badge/platform-iOS-lightgrey) ![GitHub](https://img.shields.io/github/license/swiftablellc/jabberwocky-cordova-plugin-ios)

> Head Tracking Cursor for Cordova (iOS) apps!

![cordova-gif](https://user-images.githubusercontent.com/6625903/82470605-2e87ba00-9a8b-11ea-992e-9042736d033b.gif)

## About
The Jabberwocky® Cordova Plugin wraps the Jabberwocky® Head Tracking Kit ([JabberwockyHTKit](https://github.com/swiftablellc/jabberwocky-head-tracking-kit-ios)). It is an open-source iOS framework, developed by Swiftable LLC, that provides a touch-free interface for existing iOS applications. Jabberwocky enables users to interact with an application by just moving their head. Head movement translates into the movement of a mouse-like cursor on the screen. Cursor location and blink events can be subscribed to allowing actions to be performed in Cordova.

See [JabberwockyHTKit](https://github.com/swiftablellc/jabberwocky-head-tracking-kit-ios) for more information.

## Installation

### Create Cordova Project
```shell script
cordova create jabberwocky-cordova-app example.jabberwocky.cordova JabberwockyCordovaExample && cd jabberwocky-cordova-app
```

### Set Correct Deployment Target
* Set the iOS deployment target to `12.0` in the root `config.xml`

```xml
<widget ...>
...
  <preference name="deployment-target" value="12.0" />
...
</widget>
```

### Create iOS platform

```shell script
cordova platform add ios
```

### Install Jabberwocky HTKit Plugin

```shell script
cordova plugin add https://github.com/swiftablellc/jabberwocky-cordova-plugin-ios.git
```

### Initialize Jabberwocky in Cordova

* Modify `onDeviceReady` function in `platforms/ios/www/js/index.js`

```javascript

onDeviceReady: function() {
...
    var jabberwocky = window.plugins.JabberwockyHeadTracking;

    jabberwocky.configure(jabberwocky.getDefaultCordovaFeatures(), function() {
        jabberwocky.enable(function() {
            console.log("Jabberwocky Enabled!");
        });
    });
...
}
```

## Test

* Run on a physical device (FaceID device required).
