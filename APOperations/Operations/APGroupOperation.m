//
//  APGroupOperation.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APGroupOperation.h"

#import "APOperationQueue.h"

@interface APGroupOperation () <APOperationQueueDelegate>

@end

@implementation APGroupOperation {
    APOperationQueue *_internalQueue;
    NSBlockOperation *_startingOperation;
    NSBlockOperation *_finishingOperation;
    NSMutableArray<NSError *> *_aggregatedErrors;
}

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithOperatons:@[]];
}

- (instancetype)initWithOperatons:(NSArray<NSOperation *> *)operations {
    self = [super init];
    if (self) {
        _aggregatedErrors = [NSMutableArray new];
        
        _startingOperation = [NSBlockOperation blockOperationWithBlock:^{}];
        _finishingOperation = [NSBlockOperation blockOperationWithBlock:^{}];
        
        _internalQueue = [APOperationQueue new];
        _internalQueue.suspended = YES;
        _internalQueue.delegate = self;
        [_internalQueue addOperation:_startingOperation];
        
        for (NSOperation *operation in operations) {
            [_internalQueue addOperation:operation];
        }
    }
    return self;
}

#pragma mark - NSOperation

- (void)cancel {
    [_internalQueue cancelAllOperations];
    _internalQueue.suspended = NO;
    [super cancel];
}

#pragma mark - APOperation

- (void)execute {
    _internalQueue.suspended = NO;
    [_internalQueue addOperation:_finishingOperation];
}

#pragma mark - Public

- (void)addOperation:(NSOperation *)operation {
    [_internalQueue addOperation:operation];
}

- (void)operationDidFinish:(NSOperation *)operation withErrors:(NSArray<NSError *> *)errors {
    // To be implemented by subclasses
}

- (void)aggregateError:(NSError *)error {
    // Note that some part of execution has produced an error. Errors aggregated through this method will be included in the final array of errors reported to observers and to the finished: method.
    if (error) {
        [_aggregatedErrors addObject:error];
    }
}

#pragma mark - APOperationQueueDelegate

- (void)operationQueue:(APOperationQueue *)operationQueue willAddOperation:(NSOperation *)operation {
    NSAssert(!_finishingOperation.finished && !_finishingOperation.executing, @"Cannot add new operations to a group after the group has completed");
    // Some operation in this group has produced a new operation to execute. We want to allow that operation to execute before the group completes, so we'll make the finishing operation dependent on this newly-produced operation.
    if (operation != _finishingOperation) {
        [_finishingOperation addDependency:operation];
    }
    // All operations should be dependent on startingOperation. This way, we can guarantee that the conditions for other operations will not evaluate until just before the operation is about to run. Otherwise, the internal operation queue is unsuspended
    if (operation != _startingOperation) {
        [operation addDependency:_startingOperation];
    }
}

- (void)operationQueue:(APOperationQueue *)operationQueue operationDidFinish:(NSOperation *)operation withErrors:(nullable NSArray<NSError *> *)errors {
    if (errors) {
        [_aggregatedErrors addObjectsFromArray:errors];
    }
    
    if (operation == _finishingOperation) {
        _internalQueue.suspended = YES;
        [self finishWithErrors:_aggregatedErrors];
    } else if (operation != _startingOperation) {
        [self operationDidFinish:operation withErrors:errors];
    }
}

@end
