//
//  APCalendarCondition.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

@import Foundation;
@import EventKit;

#import "APOperationCondition.h"

/*!
 * @class APCalendarCondition
 * @abstract A condition for verifying access to the user's calendar
 */
@interface APCalendarCondition : NSObject <APOperationCondition>

@property (nonatomic, readonly) EKEntityType entityType;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithEntityType:(EKEntityType)entityType NS_DESIGNATED_INITIALIZER;

@end
