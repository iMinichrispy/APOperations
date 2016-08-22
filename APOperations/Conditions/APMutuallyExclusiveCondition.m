//
//  APMutuallyExclusiveCondition.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APMutuallyExclusiveCondition.h"

#import "APInvalidInitializerMacro.h"

@interface APMutuallyExclusiveCondition ()

@property (nonatomic, strong, nonnull) NSString *type;

@end

@implementation APMutuallyExclusiveCondition

#pragma mark - Initializers

+ (instancetype)conditionWithType:(NSString *)type {
    APMutuallyExclusiveCondition *exclusiveCondition = [[APMutuallyExclusiveCondition alloc] init];
    exclusiveCondition.type = type;
    return exclusiveCondition;
}

#pragma mark - APOperationCondition

- (NSString *)name {
    return [NSStringFromClass([self class]) stringByAppendingFormat:@"<%@>", _type];
}

- (BOOL)isMutuallyExclusive {
    return YES;
}

- (NSOperation *)dependencyForOperation:(APOperation *)operation {
    return nil;
}

- (void)evaluateForOperation:(APOperation *)operation completion:(APOperationConditionCompletionHandler)completion {
    if (completion) {
        completion(APOperationConditionResultSatisfied, nil);
    }
}

@end
