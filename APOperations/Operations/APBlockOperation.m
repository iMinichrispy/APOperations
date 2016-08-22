//
//  APBlockOperation.m
//  APOperations
//
//  Created by Alex Perez on 11/27/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APBlockOperation.h"

#import "APInvalidInitializerMacro.h"

@implementation APBlockOperation {
    APBlockOperationBlock _block;
}

AP_INVALID_INITIALIZER(init);

- (instancetype)initWithBlock:(APBlockOperationBlock)block {
    self = [super init];
    if (self) {
        _block = block;
    }
    return self;
}

+ (instancetype)blockOperationWithBlock:(APBlockOperationBlock)block {
    return [[self alloc] initWithBlock:block];
}

- (instancetype)initWithMainQueueBlock:(dispatch_block_t)mainQueueBlock {
    self = [self initWithBlock:^(APBlockOperationContinuation _Nonnull continuation) {
        dispatch_async(dispatch_get_main_queue(), ^{
            mainQueueBlock();
            continuation();
        });
    }];
    return self;
}

+ (instancetype)mainQueueBlock:(dispatch_block_t)mainQueueBlock {
    return [[self alloc] initWithMainQueueBlock:mainQueueBlock];
}

- (void)execute {
    if (_block) {
        _block(^{
            // TODO: What goes here?
        });
        [self finishWithError:nil];
    } else {
        [self finishWithError:nil];
    }
}

@end
