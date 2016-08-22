//
//  APDelayOperation.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APDelayOperation.h"

typedef NS_ENUM(NSInteger, APDelayOperationType) {
    APDelayOperationTypeTimeInterval,
    APDelayOperationTypeUntilDate
};

@implementation APDelayOperation {
    APDelayOperationType _type;
    NSTimeInterval _interval;
    NSDate *_date;
}

#pragma mark - Initialization

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval {
    self = [super init];
    if (self) {
        _type = APDelayOperationTypeTimeInterval;
        _interval = interval;
    }
    return self;
}

- (instancetype)initWithUntilDate:(NSDate *)date {
    self = [super init];
    if (self) {
        _type = APDelayOperationTypeUntilDate;
        _date = date;
    }
    return self;
}

#pragma mark - NSOperation

- (void)cancel {
    [super cancel];
    // Cancelling the operation means we don't want to wait anymore.
    [self finishWithError:nil];
}

#pragma mark - APOperation

- (void)execute {
    // Figure out how long we should wait for
    NSTimeInterval interval = 0;
    if (_type == APDelayOperationTypeTimeInterval) {
        interval = _interval;
    } else if (_type == APDelayOperationTypeUntilDate) {
        interval = _date.timeIntervalSinceNow;
    }
    
    if (interval <= 0) {
        [self finishWithError:nil];
        return;
    }
    
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC);
    dispatch_after(when, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        // If we were cancelled, then finish() has already been called.
        if (!self.cancelled) {
            [self finishWithError:nil];
        }
    });
}

@end
