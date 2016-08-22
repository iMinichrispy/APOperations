//
//  APLocationOperation.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APOperation.h"

@import CoreLocation;

NS_ASSUME_NONNULL_BEGIN

typedef void(^APLocationOperationCompletionHandler)(CLLocation * __nullable location);

/*!
 * @class APLocationOperation
 * @abstract A subclass of `APOperation` to do a one-shot request to get the user's current location, with a desired accuracy
 * @discussion This operation will prompt for "When in Use" location authorization, if the app does not already have it
 */
@interface APLocationOperation : APOperation

@property (nonatomic, readonly) CLLocationAccuracy accuracy;
@property (nonatomic, copy, readonly) APLocationOperationCompletionHandler completion;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAccuracy:(CLLocationAccuracy)accuracy completion:(APLocationOperationCompletionHandler)completion NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
