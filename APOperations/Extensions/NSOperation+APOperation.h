//
//  NSOperation+APOperation.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSOperation (APOperation)

/*!
 * @abstract Add a completion block to be executed after the `NSOperation` enters the "finished" state
 */
- (void)ap_addCompletionBlock:(void(^)(void))completion;

/*!
 * @abstract Add multiple depdendencies to the operation
 */
- (void)ap_addDependencies:(NSArray<NSOperation *> *)dependencies;

@end

NS_ASSUME_NONNULL_END
