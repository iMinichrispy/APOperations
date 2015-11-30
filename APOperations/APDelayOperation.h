//
//  APDelayOperation.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APOperation.h"

/*!
 * @class APDelayOperation
 * @abstract A subclass of `APOperation` that will wait for a given time interval or until a specific `NSDate`
 * @note It is important to note that this operation does **not** use the `sleep()` function, since that is inefficient and blocks the thread on which it is called. Instead, this operation uses `dispatch_after` to know when the appropriate time has passed.
 * @discussion If the time interval is negative, or the `NSDate` is in the past, then this operation immediately finishes
 */
@interface APDelayOperation : APOperation

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval;
- (instancetype)initWithUntilDate:(NSDate *)date;

@end
