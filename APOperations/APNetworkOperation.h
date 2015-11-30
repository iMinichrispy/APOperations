//
//  APNetworkOperation.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APOperation.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^APNeworkOperationCompletionHandler)(NSData * _Nullable data, NSError * _Nullable error);

/*!
 * @class APNetworkOperation
 * @abstract A subclass of `APOperation` that lifts an `NSURLRequest` into an operation
 */
@interface APNetworkOperation : APOperation

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithRequest:(NSURLRequest *)request NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy) APNeworkOperationCompletionHandler completion;
@property (nonatomic, copy, readonly)  NSURLRequest *request;
@property (nonatomic, assign) BOOL showsNetworkActivityIndicator;

@end

NS_ASSUME_NONNULL_END
