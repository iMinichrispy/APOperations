//
//  APTimeoutObserver.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APTimeoutObserver.h"

#import "APOperation.h"
#import "NSError+APOperationErrors.h"

static NSString *const APTimeoutObserverKey = @"Timeout";

@implementation APTimeoutObserver {
    NSTimeInterval _timeout;
}

#pragma mark - Initialization

- (instancetype)initWithTimeout:(NSTimeInterval)timeout {
    self = [super init];
    if (self) {
        _timeout = timeout;
    }
    return self;
}

#pragma mark - APOperationObserver

- (void)operationDidStart:(APOperation *)operation {
    // When the operation starts, queue up a block to cause it to time out
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, _timeout * NSEC_PER_SEC);
    
    dispatch_after(when, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        // Cancel the operation if it hasn't finished and hasn't already been cancelled
        if (!operation.finished && !operation.cancelled) {
            NSError *error = [NSError operationErrorWithCode:APOperationErrorCodeExecutionFailed userInfo:@{APTimeoutObserverKey: @(_timeout)}];
            [operation cancelWithErrors:@[error]];
        }
    });
}

@end
