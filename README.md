# jabberwocky-cordova-plugin-ios
Jabberwocky Head Tracking Cordova Plugin for iOS

## Installation

### Create ios platform

```
cordova platform add ios
```

### Install Jabberwocky HTKit Plugin

```
cordova plugin add https://github.com/swiftablellc/jabberwocky-cordova-plugin-ios.git
```

### Add Camera Permissions to *-Info.plist

* Add `NSCameraUsageDescription` to platforms/ios/$PROEJCT/$PROJECT-Info.plist

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
...
	<key>NSCameraUsageDescription</key>
	<string>Uses Camera to provide Head Tracking</string>
...
</dict>
</plist>
```

### Add HTKit configuration code

* Add the following imports into MainViewController.m under `#import "MainViewController.h"`:

```objc
#import <AVFoundation/AVFoundation.h>
#import <HTKit/HTKit-Swift.h>
```


* Add the following code into MainViewController.m in `viewDidLoad` method:

```objc
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        NSLog(@"Requested Camera Permission");
        if(granted){
            dispatch_async(dispatch_get_main_queue(), ^{
                [HeadTracking configureWithSettingsAppGroup: nil completion: ^void {
                    NSLog(HeadTracking.shared.isEnabled? @"Head Tracking Enabled" : @"Head Tracking Not Enabled.");
                }];
            });
        } else {
            NSLog(@"Camera Permissions Missing for Head Tracking");
        }
    }];
```

## Test
* Run the Project on a physical device.
