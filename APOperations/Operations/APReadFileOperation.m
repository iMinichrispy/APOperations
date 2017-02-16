//
//  APReadFileOperation.m
//  GeorgiaTech
//
//  Created by Alex Perez on 5/19/16.
//  Copyright © 2016 Georgia Tech Research Corporation. All rights reserved.
//

#import "APReadFileOperation.h"

@implementation APReadFileOperation

#pragma mark - Initialization

- (instancetype)initWithFileURL:(NSURL *)fileURL completion:(APReadFileCompletionHandler)completion {
    self = [super init];
    if (self) {
        _fileURL = [fileURL copy];
        _completion = [completion copy];
    }
    return self;
}

+ (instancetype)operationWithFileURL:(NSURL *)fileURL completion:(APReadFileCompletionHandler)completion {
    return [[self alloc] initWithFileURL:fileURL completion:completion];
}

#pragma mark - APOperation

- (void)execute {
    NSParameterAssert(_fileURL);
    NSParameterAssert(_completion);
    if (!_fileURL || !_completion) {
        if (_completion) {
            _completion(nil, nil);
        }
        [self finishWithError:nil];
        return;
    }
    
    NSError *error;
    NSData *data = [[NSData alloc] initWithContentsOfURL:_fileURL options:0 error:&error];
    if (!data) {
        if (_completion) {
            _completion(nil, error);
        }
        [self finishWithError:error];
        return;
    }
    
    if (_completion) {
        _completion(data, nil);
    }
    
    [self finishWithError:nil];
}

#pragma mark - NSOperation

- (void)cancel {
    _completion = nil;
    [super cancel];
}

- (BOOL)isAsynchronous {
    return YES;
}

@end
