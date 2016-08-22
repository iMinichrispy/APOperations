//
//  NSOperation+APOperation.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "NSOperation+APOperation.h"

@implementation NSOperation (APOperation)

- (void)ap_addCompletionBlock:(nonnull void(^)())completion {
    void (^existingBlock)(void) = self.completionBlock;
    
    if (existingBlock) {
        // If we already have a completion block, construct a new one by chaining them together
        self.completionBlock = ^{
            existingBlock();
            completion();
        };
    } else {
        self.completionBlock = completion;
    }
}

- (void)ap_addDependencies:(nonnull NSArray<NSOperation *> *)dependencies {
    for (NSOperation *dependency in dependencies) {
        [self addDependency:dependency];
    }
}

@end
