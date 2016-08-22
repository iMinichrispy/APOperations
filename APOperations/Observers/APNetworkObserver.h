//
//  APNetworkObserver.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APOperationObserver.h"

/*!
 * @class APNetworkObserver
 * @abstract A `APOperationObserver` that will cause the network activity indicator to appear as long as the `APOperation` to which it is attached is executing
 */
@interface APNetworkObserver : NSObject <APOperationObserver>

@end
