//
//  APNetworkIndicatorController.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APNetworkIndicatorController.h"

#import "APInvalidInitializerMacro.h"

@interface APTimer : NSObject

- (instancetype)initWithInterval:(NSTimeInterval)interval handler:(dispatch_block_t)handler NS_DESIGNATED_INITIALIZER;
- (void)cancel;

@end

@implementation APTimer {
    BOOL _isCancelled;
}

AP_INVALID_INITIALIZER(init);

- (instancetype)initWithInterval:(NSTimeInterval)interval handler:(dispatch_block_t)handler {
    self = [super init];
    if (self) {
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC));
        dispatch_after(when, dispatch_get_main_queue(), ^{
            if (![self isCancelled]) {
                handler();
            }
        });
    }
    return self;
}

- (void)cancel {
    _isCancelled = YES;
}

- (BOOL)isCancelled {
    return _isCancelled;
}

@end

@implementation APNetworkIndicatorController {
    NSInteger _activityCount;
    APTimer *_visibilityTimer;
}

#pragma mark - Initialization

+ (instancetype)sharedController {
    static APNetworkIndicatorController *controller;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[APNetworkIndicatorController alloc] init];
    });
    return controller;
}

#pragma mark - Public

- (void)networkActivityDidStart {
    NSAssert([NSThread isMainThread], @"Altering network activity indicator state can only be done on the main thread.");
    _activityCount++;
    [self _updateIndicatorVisibility];
}

- (void)networkActivityDidEnd {
    NSAssert([NSThread isMainThread], @"Altering network activity indicator state can only be done on the main thread.");
    _activityCount--;
    [self _updateIndicatorVisibility];
}

#pragma mark - Internal

- (void)_updateIndicatorVisibility {
    if (_activityCount) {
        [self _showIndicator];
    } else {
        // To prevent the indicator from flickering on and off, we delay the hiding of the indicator by one second.
        // This provides the chance to come in and invalidate the timer before it fires.
        _visibilityTimer = [[APTimer alloc] initWithInterval:1.0 handler:^{
            [self _hideIndicator];
        }];
    }
}

- (void)_showIndicator {
    if (_visibilityTimer) {
        [_visibilityTimer cancel];
        _visibilityTimer = nil;
    }
    
#if !TARGET_OS_WATCH
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
#endif
}

- (void)_hideIndicator {
    if (_visibilityTimer) {
        [_visibilityTimer cancel];
        _visibilityTimer = nil;
    }
    
#if !TARGET_OS_WATCH
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
#endif
}

@end
