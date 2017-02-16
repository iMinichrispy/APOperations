//
//  APWriteFileOperation.h
//  APNetworking
//
//  Created by Alex Perez on 2/15/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "APOperation.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^APWriteFileCompletionHandler)(BOOL success, NSError * _Nullable error);

/*!
 * @class APWriteFileOperation
 * @abstract Writes data to a file
 */
@interface APWriteFileOperation : APOperation

@property (nonatomic, copy, readonly) NSData *data;
@property (nonatomic, copy, readonly) NSURL *fileURL;
@property (nonatomic, copy, readonly) APWriteFileCompletionHandler completion;

/*!
 * @abstract Initializes the operation
 * @param data The data to write
 * @param fileURL The resource url for the data to load
 * @param completion The block to call once the data is read
 */
+ (instancetype)operationWithData:(NSData *)data fileURL:(NSURL *)fileURL completion:(nullable APWriteFileCompletionHandler)completion;

@end

NS_ASSUME_NONNULL_END
