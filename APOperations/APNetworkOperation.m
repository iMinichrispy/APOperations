//
//  APNetworkOperation.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APNetworkOperation.h"

#import "APInvalidInitializerMacro.h"
#import "APReachabilityCondition.h"
#import "APNetworkObserver.h"

@interface NSHTTPURLResponse (APAcceptableStatusCode)

- (BOOL)ap_isStatusCodeAcceptable;

@end

@implementation NSHTTPURLResponse (APAcceptableStatusCode)

- (BOOL)ap_isStatusCodeAcceptable {
    NSIndexSet *acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    NSInteger statusCode = self.statusCode;
    return (statusCode >= 0) && [acceptableStatusCodes containsIndex:statusCode];
}

@end

@implementation APNetworkOperation {
    NSURLSessionTask *_task;
}

AP_INVALID_INITIALIZER(init);

- (instancetype)initWithRequest:(NSURLRequest *)request {
    self = [super init];
    if (self) {
        _request = [request copy];
        
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:_request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (!error && !data.length) {
                NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
                if (![httpURLResponse ap_isStatusCodeAcceptable]) {
                    error = [NSError errorWithDomain:NSURLErrorDomain code:httpURLResponse.statusCode userInfo:nil];
                }
            }
            
            if (_completion) {
                _completion(data, error);
            }
            
            if (error) {
                [self finishWithErrors:@[error]];
            } else {
                [self finishWithErrors:nil];
            }
        }];
        _task = task;
    }
    return self;
}

- (void)execute {
    NSAssert(_task.state == NSURLSessionTaskStateSuspended, @"Task was resumed by something other than self");
    [_task resume];
}

- (BOOL)isAsynchronous {
    return YES;
}

- (void)cancel {
    [_task cancel];
    _completion = nil;
    [super cancel];
}

- (void)setShowsNetworkActivityIndicator:(BOOL)showsNetworkActivityIndicator {
    if (_showsNetworkActivityIndicator != showsNetworkActivityIndicator) {
        _showsNetworkActivityIndicator = showsNetworkActivityIndicator;
        if (_showsNetworkActivityIndicator) {
            APNetworkObserver *networkObserver = [[APNetworkObserver alloc] init];
            [self addObserver:networkObserver];
        } else {
            NSAssert(NO, @"Network observer cannot be removed after it has already been added");
        }
    }
}

@end
