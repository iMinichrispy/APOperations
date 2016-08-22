//
//  APBlockObserver.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APBlockObserver.h"

@implementation APBlockObserver {
    APBlockObserverStartHandler _startHandler;
    APBlockObserverCancelHandler _cancelHandler;
    APBlockObserverProduceHandler _produceHandler;
    APBlockObserverFinishHandler _finishHandler;
}

#pragma mark - Initializers

- (instancetype)init {
    return [self initWithStartHandler:NULL cancelHandler:NULL produceHandler:NULL finishHandler:NULL];
}

- (instancetype)initWithStartHandler:(nullable APBlockObserverStartHandler)startHandler cancelHandler:(nullable APBlockObserverCancelHandler)cancelHandler produceHandler:(nullable APBlockObserverProduceHandler)produceHandler finishHandler:(nullable APBlockObserverFinishHandler)finishHandler {
    self = [super init];
    if (self) {
        _startHandler = [startHandler copy];
        _cancelHandler = [cancelHandler copy];
        _produceHandler = [produceHandler copy];
        _finishHandler = [finishHandler copy];
    }
    return self;
}

#pragma mark - APOperationObserver

- (void)operationDidStart:(APOperation *)operation {
    if (_startHandler) {
        _startHandler(operation);
    }
}

- (void)operationDidCancel:(APOperation *)operation {
    if (_cancelHandler) {
        _cancelHandler(operation);
    }
}

- (void)operation:(APOperation *)operation didProduceOperation:(NSOperation *)newOperation {
    if (_produceHandler) {
        _produceHandler(operation, newOperation);
    }
}

- (void)operationDidFinish:(APOperation *)operation errors:(NSArray<NSError *> *)errors {
    if (_finishHandler) {
        _finishHandler(operation, errors);
    }
}

@end
