//
//  APBlockOperation.h
//  APOperations
//
//  Created by Alex Perez on 11/27/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APOperation.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^APBlockOperationContinuation)();
typedef void(^APBlockOperationBlock)(APBlockOperationContinuation continuation);

/*!
 * @class APBlockOperation
 * @abstract A subclass of `APOperation` for executing a block
 */
@interface APBlockOperation : APOperation

- (instancetype)init NS_UNAVAILABLE;

/*!
 * @abstract The designated initializer
 * @discussion The block *must* be invoked by your code or else the `APBlockOperation` will never finish executing
 * @note If the block parameter is `nil`, the operation will immediately finish
 * @param block, the block to run when the operation executes
 */
+ (instancetype)blockOperationWithBlock:(APBlockOperationBlock)block;

/*!
 * @abstract A convenience initializer to execute a block on the main queue
 * @discussion The operation will automatically be ended after `mainQueueBlock` is executed
 * @note The mainQueueBlock does not have a "continuation" block to execute (unlike the designated initializer)
 * @param mainQueueBlock, the block to execute on the main queue
 */
+ (instancetype)mainQueueBlock:(dispatch_block_t)mainQueueBlock;

@end

NS_ASSUME_NONNULL_END
