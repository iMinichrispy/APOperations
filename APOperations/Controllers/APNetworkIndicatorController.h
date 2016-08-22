//
//  APNetworkIndicatorController.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

@import UIKit;

/*!
 * @class APNetworkIndicatorController
 * @abstract A singleton to manage a visual "reference count" on the network activity indicator
 */
@interface APNetworkIndicatorController : NSObject

+ (instancetype)sharedController;

- (void)networkActivityDidStart;
- (void)networkActivityDidEnd;

@end
