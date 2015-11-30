//
//  APOperationCondition.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, APOperationConditionResult) {
    APOperationConditionResultSatisfied,
    APOperationConditionResultFailed,
};

typedef void(^APOperationConditionCompletionHandler)(APOperationConditionResult result, NSError * __nullable error);

@class APOperation;

/*!
 * @protocol APOperationCondition
 * @abstract A protocol for defining conditions that must be satisfied in order for an operation to begin execution
 */
@protocol APOperationCondition <NSObject>

- (NSString *)name;
- (BOOL)isMutuallyExclusive;
- (nullable NSOperation *)dependencyForOperation:(APOperation *)operation;
- (void)evaluateForOperation:(APOperation *)operation completion:(APOperationConditionCompletionHandler)completion;

@end

NS_ASSUME_NONNULL_END
