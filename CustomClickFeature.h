#import <HTKit/HTKit-Swift.h>

@interface CustomClickFeature: NSObject <HTFeature> {
    BOOL enabled;
}

+ (CustomClickFeature *) shared;

@end
