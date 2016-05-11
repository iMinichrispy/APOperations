//
//  APBlockObserver.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APOperationObserver.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^APBlockObserverStartHandler)(APOperation *operation);
typedef void(^APBlockObserverCancelHandler)(APOperation *operation);
typedef void(^APBlockObserverProduceHandler)(APOperation *operation, NSOperation *newOperation);
typedef void(^APBlockObserverFinishHandler)(APOperation *operation, NSArray<NSError *> * _Nullable errors);

@class APOperation;

/*!
 * @class APBlockObserver
 * @abstract A way to attach arbitrary code blocks to significant events in a `APOperation`'s lifecycle
 */
@interface APBlockObserver : NSObject <APOperationObserver>

- (instancetype)initWithStartHandler:(nullable APBlockObserverStartHandler)startHandler cancelHandler:(nullable APBlockObserverCancelHandler)cancelHandler produceHandler:(nullable APBlockObserverProduceHandler)produceHandler finishHandler:(nullable APBlockObserverFinishHandler)finishHandler NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
