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
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
                if (!error && ![httpURLResponse ap_isStatusCodeAcceptable]) {
                    // There's no error but the status code doesn't fall in the acceptable range
                    NSDictionary<NSString *, id> *userInfo = (_request.URL) ? @{NSURLErrorFailingURLStringErrorKey: _request.URL} : nil;
                    error = [NSError errorWithDomain:NSURLErrorDomain code:httpURLResponse.statusCode userInfo:userInfo];
                }
            }
            
            if (_completion) {
                _completion(data, error);
            }
            
            [self finishWithError:error];
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
