//
//  APTestObserver.m
//  APOperations
//
//  Created by Alex Perez on 11/26/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APTestObserver.h"

@implementation APTestObserver

- (void)operationDidStart:(APOperation *)operation {
    if (_didStartBlock) {
        _didStartBlock();
    }
}

- (void)operationDidCancel:(APOperation *)operation {
    if (_didCancelBlock) {
        _didCancelBlock();
    }
}

- (void)operation:(APOperation *)operation didProduceOperation:(NSOperation *)newOperation {
    if (_didProduceBlock) {
        _didProduceBlock();
    }
}

- (void)operationDidFinish:(APOperation *)operation errors:(NSArray<NSError *> *)errors {
    _errors = errors;
    
    if (_didEndBlock) {
        _didEndBlock();
    }
}

@end
