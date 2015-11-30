//
//  APNetworkObserver.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APNetworkObserver.h"

#import "APNetworkIndicatorController.h"

@implementation APNetworkObserver

- (void)operationDidStart:(APOperation *)operation {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[APNetworkIndicatorController sharedController] networkActivityDidStart];
    });
}

- (void)operationDidFinish:(APOperation *)operation errors:(NSArray<NSError *> *)errors {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[APNetworkIndicatorController sharedController] networkActivityDidEnd];
    });
}

@end
