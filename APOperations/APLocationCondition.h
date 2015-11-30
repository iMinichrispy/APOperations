//
//  APLocationCondition.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

@import Foundation;

#import "APOperationCondition.h"

typedef NS_ENUM(NSInteger, APLocationAuthorization) {
    APLocationAuthorizationWhenInUse,
    APLocationAuthorizationAlways,
};

/*!
 * @class APLocationCondition
 * @abstract A condition for verifying access to the user's location
 */
@interface APLocationCondition : NSObject <APOperationCondition>

@property (nonatomic, readonly) APLocationAuthorization authorization;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAuthorization:(APLocationAuthorization)authorization NS_DESIGNATED_INITIALIZER;

@end
