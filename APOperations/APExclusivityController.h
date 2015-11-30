//
//  APExclusivityController.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

@import Foundation;

@class APOperation;

NS_ASSUME_NONNULL_BEGIN

/*!
 * @class APExclusivityController
 * @abstract A controller for setting up dependencies between mutually exclusive operations
 * @discussion We use a singleton because mutual exclusivity must be enforced across the entire app, regardless of the operation queue on which an operation was executed
 */
@interface APExclusivityController : NSObject

/*!
 * @abstract The shared `APExclusivityController` instance
 */
+ (instancetype)sharedController;

/*!
 * @abstract Registers an operation as being mutually exclusive
 * @param operation, the `APOperation` to add
 * @param categories, an array of `APOperationCondition` class name strings
 */
- (void)addOperation:(APOperation *)operation categories:(NSArray<NSString *> *)categories;

/*!
 * @abstract Unregisters an operation from being mutually exclusive
 * @param operation, the operation to remove
 * @param categories, an array of `APOperationCondition` class name strings
 */
- (void)removeOperation:(APOperation *)operation categories:(NSArray<NSString *> *)categories;

@end

NS_ASSUME_NONNULL_END
