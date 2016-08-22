//
//  APReachabilityCondition.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

@import Foundation;

#import "APOperationCondition.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * @class APReachabilityCondition
 * @abstract A condition that performs a very high-level reachability check
 * @note It does *not* perform a long-running reachability check, nor does it respond to changes in reachability. Reachability is evaluated once when the operation to which this is attached is asked about its readiness.
 */
@interface APReachabilityCondition : NSObject <APOperationCondition>

@property (nonatomic, strong) NSURL *host;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithHost:(NSURL *)host NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
