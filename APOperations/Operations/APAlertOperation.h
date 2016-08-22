//
//  APAlertOperation.h
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APOperation.h"

@import UIKit.UIAlertController;

@class UIViewController, APAlertOperation;

NS_ASSUME_NONNULL_BEGIN

typedef void(^APAlertOperationCompletionHandler)(APAlertOperation *alertOperation);

/*!
 * @class APAlertOperation
 * @abstract A subclass of `APOperation` that displays an alert
 */
@interface APAlertOperation : APOperation

@property (nonatomic, strong, nullable) NSString *title;
@property (nonatomic, strong, nullable) NSString *message;

- (instancetype)initWithPresentationContext:(nullable UIViewController *)presentationContext;
- (void)addActionWithTitle:(NSString *)title style:(UIAlertActionStyle)style completion:(nullable APAlertOperationCompletionHandler)completion;

@end

NS_ASSUME_NONNULL_END
