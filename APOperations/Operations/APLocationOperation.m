//
//  APLocationOperation.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APLocationOperation.h"

#import "APMutuallyExclusiveCondition.h"
#import "APLocationCondition.h"

@interface APLocationOperation () <CLLocationManagerDelegate>

@end

@implementation APLocationOperation {
    CLLocationManager *_locationManager;
    CLLocationAccuracy _accuracy;
    APLocationOperationCompletionHandler _completion;
}

#pragma mark - Initialization

- (instancetype)initWithAccuracy:(CLLocationAccuracy)accuracy completion:(APLocationOperationCompletionHandler)completion {
    self = [super init];
    if (self) {
        _completion = [completion copy];
        _accuracy = accuracy;
        
        APLocationCondition *locationCondition = [[APLocationCondition alloc] initWithAuthorization:APLocationAuthorizationWhenInUse];
        [self addCondition:locationCondition];
        
        [self addCondition:[APMutuallyExclusiveCondition conditionWithType:NSStringFromClass([CLLocationManager class])]];
    }
    return self;
}

#pragma mark - Internal

- (void)_stopLocationUpdates {
    [_locationManager stopUpdatingLocation];
    _locationManager = nil;
}

#pragma mark - NSOperation

- (void)cancel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _stopLocationUpdates];
        [super cancel];
    });
}

#pragma mark - APOperation

- (void)execute {
    dispatch_async(dispatch_get_main_queue(), ^{
        // CLLocationManager needs to be created on a thread with an active run loop, so for simplicity we do this on the main queue
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = _accuracy;
        _locationManager.delegate = self;
        
        if ([_locationManager respondsToSelector:@selector(requestLocation)]) {
            [_locationManager requestLocation];
        } else {
            [_locationManager startUpdatingLocation];
        }
    });
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *lastLocation = locations.lastObject;
    if (!lastLocation || lastLocation.horizontalAccuracy > _accuracy) {
        return;
    }
    
    [self _stopLocationUpdates];
    if (_completion) {
        _completion(lastLocation);
    }
    
    [self finishWithError:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self _stopLocationUpdates];
    if (_completion) {
        _completion(nil);
    }
    [self finishWithError:error];
}

@end
