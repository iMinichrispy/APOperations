//
//  APReadFileOperation.h
//  GeorgiaTech
//
//  Created by Alex Perez on 5/19/16.
//  Copyright © 2016 Georgia Tech Research Corporation. All rights reserved.
//

#import "APOperation.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^APReadFileCompletionHandler)(NSData * _Nullable data, NSError * _Nullable error);

/*!
 * @class APReadFileOperation
 * @abstract Reads data from a file
 */
@interface APReadFileOperation : APOperation

@property (nonatomic, copy, readonly) NSURL *fileURL;
@property (nonatomic, copy, readonly) APReadFileCompletionHandler completion;

/*!
 * @abstract Initializes the operation
 * @param fileURL The resource url for the data to load
 * @param completion The block to call once the data is read
 */
+ (instancetype)operationWithFileURL:(NSURL *)fileURL completion:(APReadFileCompletionHandler)completion;

@end

NS_ASSUME_NONNULL_END
