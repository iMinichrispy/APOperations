//
//  APWriteFileOperation.m
//  APNetworking
//
//  Created by Alex Perez on 2/15/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "APWriteFileOperation.h"

@implementation APWriteFileOperation

#pragma mark - Initialization

- (instancetype)initWithData:(NSData *)data fileURL:(NSURL *)fileURL completion:(APWriteFileCompletionHandler)completion {
    self = [super init];
    if (self) {
        _data = [data copy];
        _fileURL = [fileURL copy];
        _completion = [completion copy];
    }
    return self;
}

+ (instancetype)operationWithData:(NSData *)data fileURL:(NSURL *)fileURL completion:(APWriteFileCompletionHandler)completion {
    return [[self alloc] initWithData:data fileURL:fileURL completion:completion];
}

#pragma mark - APOperation

- (void)execute {
    NSParameterAssert(_data);
    NSParameterAssert(_fileURL);
    if (!_data || !_fileURL) {
        if (_completion) {
            _completion(NO, nil);
        }
        [self finishWithError:nil];
        return;
    }
    
    // Create file directory if necessary
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:_fileURL.path]) {
        NSError *error;
        // Remove file name from URL
        NSURL *fileDirectoryURL = [_fileURL URLByDeletingLastPathComponent];
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:fileDirectoryURL withIntermediateDirectories:YES attributes:nil error:&error];
        if (!success || error) {
            if (_completion) {
                _completion(NO, error);
            }
            [self finishWithError:error];
            return;
        }
    }
    
    NSError *error;
    BOOL success = [_data writeToURL:_fileURL options:NSDataWritingAtomic error:&error];
    if (!success) {
        if (_completion) {
            _completion(NO, error);
        }
        [self finishWithError:error];
        return;
    }
    
    if (_completion) {
        _completion(success, nil);
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
