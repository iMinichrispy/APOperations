//
//  APAlertOperation.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APAlertOperation.h"

#import "APMutuallyExclusiveCondition.h"

@import UIKit;

@interface APAlertOperation ()

@property (nonatomic, strong, nullable) UIViewController *presentationContext;

@end

@implementation APAlertOperation {
    UIAlertController *_alertController;
}

#pragma mark - Initialization

- (instancetype)initWithPresentationContext:(nullable UIViewController *)presentationContext {
    self = [super init];
    if (self) {
        _presentationContext = (presentationContext) ? presentationContext : [[UIApplication sharedApplication] keyWindow].rootViewController;
        _alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [self addCondition:[APMutuallyExclusiveCondition conditionWithType:APAlertConditionType]];
        
        //This operation modifies the view controller hierarchy. Doing this while other such operations are executing can lead to inconsistencies in UIKit. So, let's make them mutally exclusive.
        [self addCondition:[APMutuallyExclusiveCondition conditionWithType:NSStringFromClass([UIViewController class])]];
    }
    return self;
}

#pragma mark - APOperation

- (void)execute {
    if (!_presentationContext) {
        [self finishWithError:nil];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!_alertController.actions.count) {
            [self addActionWithTitle:@"OK" style:UIAlertActionStyleDefault completion:NULL];
        }
        
        [_presentationContext presentViewController:_alertController animated:YES completion:NULL];
    });
}

#pragma mark - Getters

- (NSString *)title {
    return _alertController.title;
}

- (NSString *)message {
    return _alertController.message;
}

#pragma mark - Setters

- (void)setTitle:(NSString *)title {
    _alertController.title = title;
}

- (void)setMessage:(NSString *)message {
    _alertController.message = message;
}

#pragma mark - Public

- (void)addActionWithTitle:(NSString *)title style:(UIAlertActionStyle)style completion:(nullable APAlertOperationCompletionHandler)completion {
    __weak typeof(self) weakSelf = self;
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion(weakSelf);
        }
        
        [weakSelf finishWithError:nil];
    }];
    
    [_alertController addAction:alertAction];
}

@end
