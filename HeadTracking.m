//
//  HeadTracking.m
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
#import <HTKit/HTKit-Swift.h>
#import "CustomClickFeature.h"

@interface HeadTracking : CDVPlugin
@end

@implementation HeadTracking {
    NSString* triggerCallbackId;
}

- (void)status:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"ok"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)start:(CDVInvokedUrlCommand*)command
{
    [HeadTracking ifConfiguredElseWithConfiguredCompletion: ^(HeadTracking* shared) {
        [shared enableWithCompletion: ^(BOOL success) {
            NSLog(success? @"Head Tracking Re-enabled.": @"Head Tracking Not Enabled.");
        }];
    } notConfiguredCompletion: ^void { 
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            NSLog(@"Requested Camera Permission");
            if(granted){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [HeadTracking configureWithSettingsAppGroup: nil completion: ^void {
                        // Disable all Default Features except for Cursor Draw Feature
                        for (id feature in HeadTracking.shared.features) {
                            if (![feature isKindOfClass:[CursorDrawFeature class]]) {
                                [feature disable];
                            }
                        }
                        NSArray* customFeatures = [NSArray arrayWithObject: [CustomClickFeature self]];
                        [HeadTracking withAdditionalFeatures: customFeatures];
                        NSLog(HeadTracking.shared.isEnabled? @"Head Tracking Configured and Enabled" : @"Head Tracking Configured but not enabled.");
                    }];
                });
            } else {
                NSLog(@"Camera Permissions Missing for Head Tracking");
            }
        }];
    }];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"subscribed"];
    [pluginResult setKeepCallbackAsBool:YES]; // here we tell Cordova not to cleanup the callback id after sendPluginResult()
    triggerCallbackId = command.callbackId;
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)stop:(CDVInvokedUrlCommand*)command
{
    // To disable across sessions -- [HeadTracking.shared disable];
    // Disable Head Tracking Temporarily
    [HeadTracking.shared deactivateCameraWindow];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"stopped"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)ping:(CDVInvokedUrlCommand*)command
{
    [self trigger:@"forced_event"];
}


- (void)trigger:(NSString *)type
{
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    float x = 0;
    float y = 0;

    [result setObject:[NSNumber numberWithFloat:x] forKey:@"x"];
    [result setObject:[NSNumber numberWithFloat:y] forKey:@"y"];
    [result setObject:type forKey:@"type"];

    if(triggerCallbackId) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsDictionary:result];
        [pluginResult setKeepCallbackAsBool:YES]; // here we tell Cordova not to cleanup the callback id after sendPluginResult()
        [self.commandDelegate sendPluginResult:pluginResult callbackId:triggerCallbackId];
    }
}
@end
