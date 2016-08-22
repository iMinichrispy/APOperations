//
//  APExclusivityController.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APExclusivityController.h"

#import "APOperation.h"

@implementation APExclusivityController {
    NSMutableDictionary<NSString *, NSArray<APOperation *> *> *_operations;
    dispatch_queue_t _serialQueue;
}

#pragma mark - Initialization

+ (instancetype)sharedController {
    static APExclusivityController *controller;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[APExclusivityController alloc] init];
    });
    return controller;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _operations = [NSMutableDictionary new];
        _serialQueue = dispatch_queue_create("Operations.ExclusivityController", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - Public

- (void)addOperation:(APOperation *)operation categories:(NSArray<NSString *> *)categories {
    // This needs to be a synchronous operation. If this were async, then we might not get around to adding dependencies until after the operation had already begun, which would be incorrect.
    dispatch_sync(_serialQueue, ^{
        for (NSString *category in categories) {
            [self _nonqueue_addOperation:operation category:category];
        }
    });
}

- (void)removeOperation:(APOperation *)operation categories:(NSArray<NSString *> *)categories {
    dispatch_async(_serialQueue, ^{
        for (NSString *category in categories) {
            [self _nonqueue_removeOperation:operation category:category];
        }
    });
}

#pragma mark - Internal

- (void)_nonqueue_addOperation:(APOperation *)operation category:(NSString *)category {
    NSMutableArray<APOperation *> *matchingOperations = [_operations[category] mutableCopy];
    if (!matchingOperations) {
        matchingOperations = [NSMutableArray new];
    }
    
    APOperation *lastOperation = matchingOperations.lastObject;
    if (lastOperation) {
        [operation addDependency:lastOperation];
    }
    
    [matchingOperations addObject:operation];
    _operations[category] = matchingOperations;
}

- (void)_nonqueue_removeOperation:(APOperation *)operation category:(NSString *)category {
    NSMutableArray<APOperation *> *matchingOperations = [_operations[category] mutableCopy];
    if (matchingOperations) {
        NSInteger index = [matchingOperations indexOfObject:operation];
        if (index != NSNotFound) {
            [matchingOperations removeObjectAtIndex:index];
            _operations[category] = matchingOperations;
        }
    }
}

@end
