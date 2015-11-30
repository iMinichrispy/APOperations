//
//  APReachabilityController.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APReachabilityController.h"

@import SystemConfiguration;

@implementation APReachabilityController {
    NSMutableDictionary<NSString *, id> *_reachabilityRefs;
    dispatch_queue_t _reachabilityQueue;
}

+ (instancetype)sharedController {
    static APReachabilityController *controller;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[APReachabilityController alloc] init];
    });
    return controller;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _reachabilityRefs = [NSMutableDictionary new];
        _reachabilityQueue = dispatch_queue_create("Operations.Reachability", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)requestReachabilityWithURL:(NSURL *)url completionHandler:(APReachabilityControllerCompletionHandler)completion {
    NSString *host = url.host;
    if (host) {
        dispatch_async(_reachabilityQueue, ^{
            SCNetworkReachabilityRef ref = (__bridge SCNetworkReachabilityRef)_reachabilityRefs[host];
            if (!ref) {
                ref = SCNetworkReachabilityCreateWithName(nil, host.UTF8String);
            }
            
            if (ref) {
                _reachabilityRefs[host] = (__bridge id _Nullable)(ref);
                
                BOOL reachable = NO;
                SCNetworkReachabilityFlags flags;
                if (SCNetworkReachabilityGetFlags(ref, &flags)) {
                    reachable = (flags & kSCNetworkReachabilityFlagsReachable);
                }
                completion(reachable);
            } else {
                completion(NO);
            }
        });
    } else {
        completion(NO);
    }
}

@end
