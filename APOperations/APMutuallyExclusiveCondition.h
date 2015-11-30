//
//  APMutuallyExclusiveCondition.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

@import Foundation;

#import "APOperationCondition.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const __nonnull APAlertConditionType = @"Alert";

/*!
 * @class APMutuallyExclusiveCondition
 * @abstract A generic condition for describing kinds of operations that may not execute concurrently
 */
@interface APMutuallyExclusiveCondition : NSObject <APOperationCondition>

@property (nonatomic, strong, readonly, nonnull) NSString *type;

+ (instancetype)conditionWithType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
