//
//  APOperationConditionEvaluator.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APOperationConditionEvaluator.h"

#import "APOperation.h"
#import "NSError+APOperationErrors.h"

@implementation APOperationConditionEvaluator

+ (void)evaluateConditions:(NSArray <id<APOperationCondition>> *)conditions operation:(APOperation *)operation completion:(void (^)(NSArray<NSError *> * __nullable errors))completion {
    dispatch_group_t conditionGroup = dispatch_group_create();
    
    NSMutableArray<NSError *> *errors = [NSMutableArray new];
    
    [conditions enumerateObjectsUsingBlock:^(id<APOperationCondition> _Nonnull condition, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_enter(conditionGroup);
        [condition evaluateForOperation:operation completion:^(APOperationConditionResult result, NSError * _Nullable error) {
            if (error) {
                [errors addObject:error];
            }
            dispatch_group_leave(conditionGroup);
        }];
    }];
    
    dispatch_group_notify(conditionGroup, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        if (operation.cancelled) {
            NSError *error = [NSError operationErrorWithCode:APOperationErrorCodeConditionFailed userInfo:nil];
            [errors addObject:error];
        }
        
        completion(errors);
    });
}

@end
