//
//  APTestCondition.m
//  APOperations
//
//  Created by Alex Perez on 11/26/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APTestCondition.h"

#import "NSError+APOperationErrors.h"

@implementation APTestCondition

- (instancetype)init {
    self = [super init];
    if (self) {
        _conditionBlock = ^{
            return YES;
        };
    }
    return self;
}

- (NSOperation *)dependencyForOperation:(APOperation *)operation {
    return _dependencyOperation;
}

- (void)evaluateForOperation:(APOperation *)operation completion:(APOperationConditionCompletionHandler)completion {
    if (_conditionBlock()) {
        completion(APOperationConditionResultSatisfied, nil);
    } else {
        NSError *error = [NSError operationErrorWithCode:APOperationErrorCodeConditionFailed userInfo:@{@"Failed": @YES}];
        completion(APOperationConditionResultFailed, error);
    }
}

- (NSString *)name {
    return @"TestCondition";
}

- (BOOL)isMutuallyExclusive {
    return NO;
}

@end
