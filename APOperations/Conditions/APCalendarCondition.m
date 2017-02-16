//
//  APCalendarCondition.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APCalendarCondition.h"

#import "APOperation.h"
#import "APMutuallyExclusiveCondition.h"
#import "NSError+APOperationErrors.h"

static NSString *const APCalendarConditionEKEntityTypeKey = @"EKEntityType";

@interface APCalendarPermissionOperation : APOperation

@property (nonatomic, readonly) EKEntityType entityType;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithEntityType:(EKEntityType)entityType NS_DESIGNATED_INITIALIZER;

@end

@implementation APCalendarCondition

#pragma mark - Initialization

- (instancetype)initWithEntityType:(EKEntityType)entityType {
    self = [super init];
    if (self) {
        _entityType = entityType;
    }
    return self;
}

#pragma mark - APOperationCondition

- (NSString *)name {
    return @"Calendar";
}

- (BOOL)isMutuallyExclusive {
    return NO;
}

- (NSOperation *)dependencyForOperation:(APOperation *)operation {
    APCalendarPermissionOperation *calendarPermissionOperation = [[APCalendarPermissionOperation alloc] initWithEntityType:_entityType];
    return calendarPermissionOperation;
}

- (void)evaluateForOperation:(APOperation *)operation completion:(APOperationConditionCompletionHandler)completion {
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:_entityType];
    if (authorizationStatus == EKAuthorizationStatusAuthorized) {
        completion(APOperationConditionResultSatisfied, nil);
    } else {
        // We are not authorized to access entities of this type.
        NSError *error = [NSError operationErrorWithCode:APOperationErrorCodeConditionFailed userInfo:@{APOperationConditionKey: NSStringFromClass([self class]), APCalendarConditionEKEntityTypeKey: @(_entityType)}];
        completion(APOperationConditionResultFailed, error);
    }
}

@end

@implementation APCalendarPermissionOperation

#pragma mark - Initialization

- (instancetype)initWithEntityType:(EKEntityType)entityType {
    self = [super init];
    if (self) {
        _entityType = entityType;
        
        [self addCondition:[APMutuallyExclusiveCondition conditionWithType:APAlertConditionType]];
    }
    return self;
}

#pragma mark - APOperation

- (void)execute {
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:_entityType];
    
    if (authorizationStatus == EKAuthorizationStatusNotDetermined) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self _sharedEventStore] requestAccessToEntityType:_entityType completion:^(BOOL granted, NSError * _Nullable error) {
                [self finishWithError:nil];
            }];
        });
    } else {
        [self finishWithError:nil];
    }
}

#pragma mark - Internal

- (EKEventStore *)_sharedEventStore {
    static EKEventStore *sharedEventStore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEventStore = [[EKEventStore alloc] init];
    });
    return sharedEventStore;
}

@end
