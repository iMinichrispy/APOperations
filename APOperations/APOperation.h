//
//  APOperation.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

@import Foundation;

#import "APOperationCondition.h"
#import "APOperationObserver.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * @class APOperation
 * @abstract A subclass of `NSOperation` from which all other operations should be derived
 * @discussion This class adds both conditions and observers, which allow the operation to define extended readiness requirements, as well as notify many interested parties about interesting operation state changes
 */
@interface APOperation : NSOperation

@property (nonatomic) BOOL userInitiated;
@property (nonatomic, strong, readonly) NSArray<id<APOperationCondition>> *conditions;
@property (nonatomic, strong, readonly) NSArray<id<APOperationObserver>> *observers;

- (void)addCondition:(id<APOperationCondition>)condition;
- (void)addObserver:(id<APOperationObserver>)observer;

/*!
 * @abstract The entry point of execution for all `APOperation` subclasses
 * @discussion `APOperation` subclasses should override this method to customize its execution
 */
- (void)execute;

/*!
 * @abstract Appends the errors to the operation's internal errors and cancels the operation
 * @param errors, the errors causing the operation to cancel
 */
- (void)cancelWithErrors:(nullable NSArray<NSError *> *)errors;

/*!
 * @abstract Indicates that the operation can now begin to evaluate readiness conditions, if appropriate
 */
- (void)willEnqueue;

/*!
 * @abstract Indicates the operation has produced a new operation
 * @param operation, the operation that was produced
 */
- (void)produceOperation:(NSOperation *)operation;

/*!
 * @abstract Indicates that the operation has finished execution and is ready for teardown
 * @discussion `APOperation` subclasses must call this method at the end of their execution
 * @param errors, the errors that occured during the operation's execution
 */
- (void)finishWithErrors:(nullable NSArray<NSError *> *)errors;

/*!
 * @abstract Called after an operation has finished executing
 * @discussion `APOperation` subclasses may override this method if they wish to react to the operation finishing with errors
 * @param errors, the errors that occured during the operation's execution
 */
- (void)finishedWithErrors:(nullable NSArray<NSError *> *)errors;

@end

NS_ASSUME_NONNULL_END
