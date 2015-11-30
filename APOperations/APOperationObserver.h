//
//  APOperationObserver.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

@import Foundation;

@class APOperation;

NS_ASSUME_NONNULL_BEGIN

/*!
 * @protocol APOperationObserver
 * @abstract The protocol that types may implement if they wish to be notified of significant operation lifecycle events
 */
@protocol APOperationObserver <NSObject>

@optional

/*!
 * @abstract Invoked immediately prior to the `APOperation`'s `execute:` method
 */
- (void)operationDidStart:(APOperation *)operation;

/*!
 * @abstract Invoked immediately after the first time the `APOperation`'s `cancel:` method is called
 */
- (void)operationDidCancel:(APOperation *)operation;

/*!
 * @abstract Invoked when `APOperation`'s `produceOperation:` is executed
 */
- (void)operation:(APOperation *)operation didProduceOperation:(NSOperation *)newOperation;

/*!
 * @abstract Invoked as an `APOperation` finishes, along with any errors produced during execution (or readiness evaluation)
 */
- (void)operationDidFinish:(APOperation *)operation errors:(NSArray<NSError *> *)errors;

@end

NS_ASSUME_NONNULL_END
