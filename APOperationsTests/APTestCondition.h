//
//  APTestCondition.h
//  APOperations
//
//  Created by Alex Perez on 11/26/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APOperationCondition.h"

typedef BOOL(^APTestConditionConditionBlock)();

@interface APTestCondition : NSObject <APOperationCondition>

@property (nonatomic, strong, nullable) NSOperation *dependencyOperation;
@property (nonatomic, strong, nullable) APTestConditionConditionBlock conditionBlock;

@end
