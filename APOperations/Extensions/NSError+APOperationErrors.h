//
//  NSError+APOperationErrors.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const APOperationErrorDomain;
FOUNDATION_EXPORT NSString *const APOperationConditionKey;

typedef NS_ENUM(NSUInteger, APOperationErrorCode) {
    APOperationErrorCodeConditionFailed = 1,
    APOperationErrorCodeExecutionFailed
};

/*!
 * @category APOperationErrors
 * @abstract Convencience method for constructing operation-related errors
 */
@interface NSError (APOperationErrors)

+ (instancetype)operationErrorWithCode:(APOperationErrorCode)code userInfo:(nullable NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
