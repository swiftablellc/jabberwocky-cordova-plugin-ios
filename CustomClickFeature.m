#import "CustomClickFeature.h"
#import <Foundation/Foundation.h>
#import <HTKit/HTKit-Swift.h>

@implementation CustomClickFeature

@synthesize enabled;

+ (CustomClickFeature *) shared {
    static dispatch_once_t once;
    static CustomClickFeature *shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
        [shared disable];
    });
    return shared;
}

+ (id<HTFeature> _Nonnull)configureWithFeatureEnabled:(BOOL)enabled {
    if (enabled) {
        [self.shared enable];
    }
    return self.shared;
}

- (void)enable {
    enabled = true;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cursorUpdateNotification:) name:NSNotification.htOnCursorUpdateNotificationKey object:nil];
}

- (void)disable {
    enabled = false;
    [[NSNotificationCenter defaultCenter] removeObserver:self name: NSNotification.htOnCursorUpdateNotificationKey object:nil];
}

- (void)cursorUpdateNotification:(NSNotification *)notification {
    if (notification.userInfo != nil) {
        NSDictionary* userInfo = notification.userInfo;
        CursorContext* context = (CursorContext *)userInfo[NSNotification.htCursorContextKey];
        BOOL shouldClick = context.shouldClickImmediately;
        if (shouldClick && context.smoothedScreenPoint.exists) {
            CGFloat x = context.smoothedScreenPoint.point.x;
            CGFloat y = context.smoothedScreenPoint.point.y;
            NSLog(@"Handle Click at (%f, %f) on Screen.", x, y);
        }
    }
}

@end
