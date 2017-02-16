//
//  APLocationCondition.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APLocationCondition.h"

@import CoreLocation;

#import "APOperation.h"
#import "APMutuallyExclusiveCondition.h"
#import "NSError+APOperationErrors.h"

static NSString *const APLocationServicesEnabledKey = @"CLLocationServicesEnabled";
static NSString *const APLocationAuthorizationStatusKey = @"CLAuthorizationStatus";

@interface APLocationPermissionOperation : APOperation <CLLocationManagerDelegate>

@property (nonatomic, readonly) APLocationAuthorization authorization;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAuthorization:(APLocationAuthorization)authorization NS_DESIGNATED_INITIALIZER;

@end

@implementation APLocationCondition

#pragma mark - Initialization

- (instancetype)initWithAuthorization:(APLocationAuthorization)authorization {
    self = [super init];
    if (self) {
        _authorization = authorization;
    }
    return self;
}

#pragma mark - APOperationCondition

- (NSString *)name {
    return @"Location";
}

- (BOOL)isMutuallyExclusive {
    return NO;
}

- (nullable NSOperation *)dependencyForOperation:(APOperation *)operation {
    APLocationPermissionOperation *locationPermissionOperation = [[APLocationPermissionOperation alloc] initWithAuthorization:_authorization];
    return locationPermissionOperation;
}

- (void)evaluateForOperation:(APOperation *)operation completion:(APOperationConditionCompletionHandler)completion {
    BOOL enabled = [CLLocationManager locationServicesEnabled];
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    
    NSError *error;
    if (enabled && authorizationStatus == kCLAuthorizationStatusAuthorizedAlways) {
        // The service is enabled, and we have "Always" permission -> condition satisfied
    } else if (enabled && _authorization == APLocationAuthorizationWhenInUse && authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // The service is enabled, and we have and need "WhenInUse" permission -> condition satisfied
    } else {
        // Anything else is an error. Maybe location services are disabled,
        // or maybe we need "Always" permission but only have "WhenInUse",
        // or maybe access has been restricted or denied,
        // or maybe access hasn't been request yet.
        error = [NSError operationErrorWithCode:APOperationErrorCodeConditionFailed userInfo:@{APOperationConditionKey: NSStringFromClass([self class]), APLocationServicesEnabledKey: @(enabled), APLocationAuthorizationStatusKey: @(authorizationStatus)}];
    }
    
    if (error) {
        completion(APOperationConditionResultFailed, error);
    } else {
        completion(APOperationConditionResultSatisfied, nil);
    }
}

@end

@implementation APLocationPermissionOperation {
    CLLocationManager *_manager;
}

#pragma mark - Initialization

- (instancetype)initWithAuthorization:(APLocationAuthorization)authorization {
    self = [super init];
    if (self) {
        _authorization = authorization;
        
        // This is an operation that potentially presents an alert so it should be mutually exclusive with anything else that presents an alert
        [self addCondition:[APMutuallyExclusiveCondition conditionWithType:APAlertConditionType]];
    }
    return self;
}

#pragma mark - APOperation

- (void)execute {
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    
    // Not only do we need to handle the Not Determined case, but we also need to handle the "upgrade" (When In Use -> Always) case
    if (authorizationStatus == kCLAuthorizationStatusNotDetermined || (authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse && _authorization == APLocationAuthorizationAlways)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _requestPermission];
        });
    } else {
        [self finishWithError:nil];
    }
}

#pragma mark - Internal

- (void)_requestPermission {
    _manager = [[CLLocationManager alloc] init];
    _manager.delegate = self;
    
    NSString *key;
    if (_authorization == APLocationAuthorizationWhenInUse) {
        key = @"NSLocationWhenInUseUsageDescription";
        [_manager requestWhenInUseAuthorization];
    } else if (_authorization == APLocationAuthorizationAlways) {
        key = @"NSLocationAlwaysUsageDescription";
        [_manager requestAlwaysAuthorization];
    }
    
    NSAssert([[NSBundle mainBundle] objectForInfoDictionaryKey:key] != nil, @"Requesting location permission requires the usage description key in your Info.plist");
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (manager == _manager && self.isExecuting && status != kCLAuthorizationStatusNotDetermined) {
        [self finishWithError:nil];
    }
}

@end
