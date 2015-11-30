//
//  APBackgroundObserver.m
//  APOperations
//
//  Created by Alex Perez on 11/26/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APBackgroundObserver.h"

@import UIKit;

@implementation APBackgroundObserver {
    UIBackgroundTaskIdentifier _identifier;
    BOOL _isInBackground;
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _identifier = UIBackgroundTaskInvalid;
        
        // We need to know when the application moves to/from the background.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        _isInBackground = [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
        
        // If we're in the background already, immediately begin the background task.
        if (_isInBackground) {
            [self _startBackgroundTask];
        }
    }
    return self;
}

#pragma mark - Deallocation

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Internal

- (void)_startBackgroundTask {
    if (_identifier == UIBackgroundTaskInvalid) {
        _identifier = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"BackgroundObserver" expirationHandler:^{
            [self _endBackgroundTask];
        }];
    }
}

- (void)_endBackgroundTask {
    if (_identifier != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:_identifier];
        _identifier = UIBackgroundTaskInvalid;
    }
}

#pragma mark - Notifications

- (void)didEnterBackground:(NSNotification *)notification {
    if (!_isInBackground) {
        _isInBackground = YES;
        [self _startBackgroundTask];
    }
}

- (void)didEnterForeground:(NSNotification *)notification {
    if (_isInBackground) {
        _isInBackground = NO;
        [self _endBackgroundTask];
    }
}

#pragma mark - APOperationObserver

- (void)operationDidFinish:(APOperation *)operation errors:(NSArray<NSError *> *)errors {
    [self _endBackgroundTask];
}

@end
