//
//  NSError+APOperationErrors.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "NSError+APOperationErrors.h"

NSString *const APOperationErrorDomain = @"APOperationErrorDomain";
NSString *const APOperationConditionKey = @"APOperationCondition";

@implementation NSError (APOperationErrors)

+ (instancetype)operationErrorWithCode:(APOperationErrorCode)code userInfo:(nullable NSDictionary *)userInfo {
    return [NSError errorWithDomain:APOperationErrorDomain code:code userInfo:userInfo];
}

@end
