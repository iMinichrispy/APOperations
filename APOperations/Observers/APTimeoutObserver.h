//
//  APTimeoutObserver.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APOperationObserver.h"

/*!
 * @class APTimeoutObserver
 * @abstract A `APOperationObserver` that will make an `APOperation` automatically time out and cancel after a specified time interval
 */
@interface APTimeoutObserver : NSObject <APOperationObserver>

- (instancetype)initWithTimeout:(NSTimeInterval)timeout NS_DESIGNATED_INITIALIZER;

@end
