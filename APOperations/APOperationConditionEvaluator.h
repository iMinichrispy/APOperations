//
//  APOperationConditionEvaluator.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

@import Foundation;

#import "APOperationCondition.h"

NS_ASSUME_NONNULL_BEGIN

@class APOperation;

/*!
 * @class APOperationConditionEvaluator
 * @abstract A class for evaluating operation conditions
 */
@interface APOperationConditionEvaluator : NSObject

+ (void)evaluateConditions:(NSArray <id<APOperationCondition>> *)conditions operation:(APOperation *)operation completion:(void (^)(NSArray<NSError *> * __nonnull errors))completion;

@end

NS_ASSUME_NONNULL_END
