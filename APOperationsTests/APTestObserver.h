//
//  APTestObserver.h
//  APOperations
//
//  Created by Alex Perez on 11/26/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APOperationObserver.h"

typedef void(^APTestObserverBlock)();

@interface APTestObserver : NSObject <APOperationObserver>

@property (nonatomic, strong, nullable) NSArray<NSError *> *errors;
@property (nonatomic, strong, nullable) APTestObserverBlock didStartBlock;
@property (nonatomic, strong, nullable) APTestObserverBlock didEndBlock;
@property (nonatomic, strong, nullable) APTestObserverBlock didCancelBlock;
@property (nonatomic, strong, nullable) APTestObserverBlock didProduceBlock;

@end
