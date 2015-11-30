//
//  APReachabilityController.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

@import Foundation;

typedef void(^APReachabilityControllerCompletionHandler)(BOOL reachable);

NS_ASSUME_NONNULL_BEGIN

/*!
 * @class APReachabilityController
 * @abstract A singleton that maintains a basic cache of `SCNetworkReachability` objects.
 */
@interface APReachabilityController : NSObject

+ (instancetype)sharedController;

- (void)requestReachabilityWithURL:(NSURL *)url completionHandler:(APReachabilityControllerCompletionHandler)completion;

@end

NS_ASSUME_NONNULL_END
