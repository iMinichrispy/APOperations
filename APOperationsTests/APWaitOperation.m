//
//  APWaitOperation.m
//  APOperations
//
//  Created by Alex Perez on 11/27/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APWaitOperation.h"

@implementation APWaitOperation

- (void)waitUntilFinished {
    _waitCalled = YES;
}

@end
