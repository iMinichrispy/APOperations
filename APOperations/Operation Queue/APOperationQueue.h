//
//  APOperationQueue.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

@import Foundation;

@class APOperationQueue;

NS_ASSUME_NONNULL_BEGIN

/*!
 * @protocol APOperationQueueDelegate
 * @abstract A delegate for responding to `APOperation` lifecycle events
 * @discussion In general, implementing `APOperationQueueDelegate` is not necessary; you would want to use a `APOperationObserver` instead
 */
@protocol APOperationQueueDelegate <NSObject>

@optional
- (void)operationQueue:(APOperationQueue *)operationQueue willAddOperation:(NSOperation *)operation;
- (void)operationQueue:(APOperationQueue *)operationQueue operationDidFinish:(NSOperation *)operation withErrors:(nullable NSArray<NSError *> *)errors;

@end

/*!
 * @class APOperationQueue
 * @abstract A subclass of `NSOperationQueue` that implements a number of extra features related to the `APOperation` class
 * @discussion Features include: notifying a delegate of all operation completion, extracting generated dependencies from operation conditions, setting up dependencies to enfore mutual exclusivity
 */
@interface APOperationQueue : NSOperationQueue

@property (nonatomic, weak, nullable) id<APOperationQueueDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
