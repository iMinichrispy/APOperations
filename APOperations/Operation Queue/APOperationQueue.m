//
//  APOperationQueue.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APOperationQueue.h"

#import "APOperation.h"
#import "APBlockObserver.h"
#import "APExclusivityController.h"
#import "NSOperation+APOperation.h"

@implementation APOperationQueue

#pragma mark - NSOperationQueue

- (void)addOperation:(NSOperation *)operation {
    if ([operation isKindOfClass:[APOperation class]]) {
        APOperation *op = (APOperation *)operation;
        
        __weak typeof(self) weakSelf = self;
        APBlockObserver *delegateObserver = [[APBlockObserver alloc] initWithStartHandler:NULL cancelHandler:NULL produceHandler:^(APOperation *existingOperation, NSOperation *newOperation) {
            [weakSelf addOperation:newOperation];
        } finishHandler:^(APOperation *finishedOperation, NSArray<NSError *> * _Nullable errors) {
            if ([_delegate respondsToSelector:@selector(operationQueue:operationDidFinish:withErrors:)]) {
                [_delegate operationQueue:weakSelf operationDidFinish:finishedOperation withErrors:errors];
            }
        }];
        [op addObserver:delegateObserver];
        
        // Extract any dependencies needed by this operation
        NSMutableArray<NSOperation *> *dependencies = [NSMutableArray new];
        for (id<APOperationCondition> condition in op.conditions) {
            NSOperation *dependencyOperation = [condition dependencyForOperation:op];
            if (dependencyOperation) {
                [dependencies addObject:dependencyOperation];
            }
        }
        
        for (NSOperation *dependency in dependencies) {
            [op addDependency:dependency];
            [self addOperation:dependency];
        }
        
        // Check if dependencies need to enforce mutual exclusivity
        NSMutableArray<NSString *> *concurrencyCategories = [NSMutableArray new];
        for (id<APOperationCondition> condition in op.conditions) {
            if ([condition isMutuallyExclusive]) {
                [concurrencyCategories addObject:[condition name]];
            }
        }
        
        if (concurrencyCategories.count) {
            // Set up mutual exclusivity dependencies
            APExclusivityController *exclusivityController = [APExclusivityController sharedController];
            [exclusivityController addOperation:op categories:concurrencyCategories];
            
            APBlockObserver *exclusivityObserver = [[APBlockObserver alloc] initWithStartHandler:NULL cancelHandler:NULL produceHandler:NULL finishHandler:^(APOperation *finishedOperation, NSArray<NSError *> *errors) {
                [exclusivityController removeOperation:finishedOperation categories:concurrencyCategories];
            }];
            [op addObserver:exclusivityObserver];
        }
        
        // Indicate to the operation that we've finished our extra work on it and it's now in a state where it can proceed with evaluating conditions, if appropriate
        [op willEnqueue];
    } else {
        // For regular NSOperation's, we'll manually call out to the queue's delegate
        // We don't want to just capture "operation" because that would lead to the operation strongly referencing itself and that's the pure definition of a memory leak.
        __weak typeof(self) weakSelf = self;
        __weak typeof(operation) weakOperation = operation;
        [operation ap_addCompletionBlock:^{
            if (weakSelf && weakOperation) {
                if ([weakSelf.delegate respondsToSelector:@selector(operationQueue:operationDidFinish:withErrors:)]) {
                    [weakSelf.delegate operationQueue:weakSelf operationDidFinish:weakOperation withErrors:nil];
                }
            }
        }];
    }
    
    if ([_delegate respondsToSelector:@selector(operationQueue:willAddOperation:)]) {
        [_delegate operationQueue:self willAddOperation:operation];
    }
    [super addOperation:operation];
}

- (void)addOperations:(NSArray<NSOperation *> *)operations waitUntilFinished:(BOOL)wait {
    // The base implementation of this method does not call addOperation: so we'll call it ourselves
    for (NSOperation *operation in operations) {
        [self addOperation:operation];
    }
    
    if (wait) {
        [operations makeObjectsPerformSelector:@selector(waitUntilFinished)];
    }
}

@end
