//
//  APInvalidInitializerMacro.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

// Thanks to Cocoa at Tumblr:
// http://cocoa.tumblr.com/post/117719761353/nullability-and-inherited-initializers-in-objective-c

#define AP_INVALID_INITIALIZER(initializer) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wobjc-designated-initializers\"") \
- (instancetype)initializer { \
NSAssert(NO, @"The initializer %s is not available.", __PRETTY_FUNCTION__); \
return nil; \
} \
_Pragma("clang diagnostic pop")
