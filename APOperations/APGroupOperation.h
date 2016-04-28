//
//  APGroupOperation.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APOperation.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * @class APGroupOperation
 * @abstract A subclass of `APOperation` that executes zero or more operations as part of its own execution
 * @discussion This class of operation is very useful for abstracting several smaller operations into a larger operation
 */
@interface APGroupOperation : APOperation

- (instancetype)initWithOperatons:(NSArray<NSOperation *> *)operations NS_DESIGNATED_INITIALIZER;
- (void)addOperation:(NSOperation *)operation;
- (void)aggregateError:(NSError *)error;
- (void)operationDidFinish:(NSOperation *)operation withErrors:(NSArray<NSError *> *)errors;

@end

NS_ASSUME_NONNULL_END
