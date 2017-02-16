//
//  APReachabilityCondition.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APReachabilityCondition.h"

#import "APReachabilityController.h"
#import "NSError+APOperationErrors.h"

static NSString *const APReachabilityConditionHostKey = @"Host";

@implementation APReachabilityCondition

#pragma mark - Initializers

- (instancetype)initWithHost:(NSURL *)host {
    self = [super init];
    if (self) {
        _host = host;
    }
    return self;
}

#pragma mark - APOperationCondition

- (NSString *)name {
    return @"Reachability";
}

- (BOOL)isMutuallyExclusive {
    return NO;
}

- (nullable NSOperation *)dependencyForOperation:(APOperation *)operation {
    return nil;
}

- (void)evaluateForOperation:(APOperation *)operation completion:(APOperationConditionCompletionHandler)completion {
    [[APReachabilityController sharedController] requestReachabilityWithURL:_host completionHandler:^(BOOL reachable) {
        if (reachable) {
            completion(APOperationConditionResultSatisfied, nil);
        } else {
            NSError *error = [NSError operationErrorWithCode:APOperationErrorCodeConditionFailed userInfo:@{APOperationConditionKey: [self name], APReachabilityConditionHostKey: _host}];
            completion(APOperationConditionResultFailed, error);
        }
    }];
}

@end
