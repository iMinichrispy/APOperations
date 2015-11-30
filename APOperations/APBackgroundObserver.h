//
//  APBackgroundObserver.h
//  APOperations
//
//  Created by Alex Perez on 11/26/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APOperationObserver.h"

/*!
 * @class APBackgroundObserver
 * @abstract A `APOperationObserver` that will automatically begin and end a background task if the application transitions to the background
 * @discussion This would be useful if you had a vital `APOperation` whose execution *must* complete, regardless of the activation state of the app
 */
@interface APBackgroundObserver : NSObject <APOperationObserver>

@end
