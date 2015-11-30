//
//  APOperations.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

//
// Converted to Objective-C from Apple's 'Advanced NSOperations' sample code
// https://developer.apple.com/videos/play/wwdc2015-226/
//
// Additional changes integrated from PSOperations framework
// https://github.com/pluralsight/PSOperations
//

@import Foundation;

#import <APOperations/APOperationQueue.h>
#import <APOperations/APExclusivityController.h>

#import <APOperations/APOperation.h>
#import <APOperations/APBlockOperation.h>
#import <APOperations/APGroupOperation.h>
#import <APOperations/APNetworkOperation.h>
#import <APOperations/APLocationOperation.h>
#import <APOperations/APAlertOperation.h>
#import <APOperations/APDelayOperation.h>

#import <APOperations/APOperationObserver.h>
#import <APOperations/APBlockObserver.h>
#import <APOperations/APNetworkObserver.h>
#import <APOperations/APTimeoutObserver.h>
#import <APOperations/APBackgroundObserver.h>

#import <APOperations/APOperationCondition.h>
#import <APOperations/APReachabilityCondition.h>
#import <APOperations/APMutuallyExclusiveCondition.h>
#import <APOperations/APLocationCondition.h>
#import <APOperations/APCalendarCondition.h>
#import <APOperations/APOperationConditionEvaluator.h>

#import <APOperations/APReachabilityController.h>
#import <APOperations/APNetworkIndicatorController.h>

#import <APOperations/NSOperation+APOperation.h>
#import <APOperations/NSError+APOperationErrors.h>
