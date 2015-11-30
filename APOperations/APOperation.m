//
//  APOperation.m
//  APOperations
//
//  Created by Alex Perez on 11/4/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

#import "APOperation.h"

#import "APOperationConditionEvaluator.h"

typedef NS_ENUM(NSInteger, APOperationState) {
    APOperationStateInitialized,
    APOperationStatePending,
    APOperationStateEvaluatingConditions,
    APOperationStateReady,
    APOperationStateExecuting,
    APOperationStateFinishing,
    APOperationStateFinished
};

@interface APOperation ()

@property (atomic) APOperationState state;
@property (atomic) BOOL cancelledState;

@end

@implementation APOperation {
    NSLock *_stateLock;
    NSRecursiveLock *_readyLock;
    NSMutableArray<NSError *> *_internalErrors;
    NSMutableArray<id<APOperationCondition>> *_conditions;
    NSMutableArray<id<APOperationObserver>> *_observers;
    BOOL _hasFinishedAlready;
    BOOL _cancelledState;
    APOperationState _state;
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _state = APOperationStateInitialized;
        _stateLock = [NSLock new];
        _readyLock = [NSRecursiveLock new];
        _internalErrors = [NSMutableArray new];
        _observers = [NSMutableArray new];
        _conditions = [NSMutableArray new];
    }
    return self;
}

#pragma mark - Getters

- (APOperationState)state {
    [_stateLock lock];
    APOperationState state = _state;
    [_stateLock unlock];
    return state;
}

- (BOOL)userInitiated {
    return self.qualityOfService == NSQualityOfServiceUserInitiated;
}

- (BOOL)cancelledState {
    return _cancelledState;
}

#pragma mark - Setters

- (void)setState:(APOperationState)state {
    // It's important to note that the KVO notifications are NOT called from inside the lock. If they were, the app would deadlock, because in the middle of calling the didChangeValueForKey: method, the observers try to access properties like "isReady" or "isFinished". Since those methods also acquire the lock, then we'd be stuck waiting on our own lock. It's the classic definition of deadlock.
    [self willChangeValueForKey:NSStringFromSelector(@selector(state))];
    [_stateLock lock];
    
    if (_state == APOperationStateFinished) {
        [_stateLock unlock];
        return;
    }
    
    NSAssert([self _canTransitionToState:state], @"Performing invalid state transition.");
    _state = state;
    
    [_stateLock unlock];
    [self didChangeValueForKey:NSStringFromSelector(@selector(state))];
}

- (void)setUserInitiated:(BOOL)userInitiated {
    NSAssert(self.state < APOperationStateExecuting, @"Cannot modify userInitiated after execution has begun.");
    self.qualityOfService = userInitiated ? NSQualityOfServiceUserInitiated : NSQualityOfServiceDefault;
}

- (void)setCancelledState:(BOOL)cancelledState {
    if (_cancelledState != cancelledState) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(cancelledState))];
        _cancelledState = cancelledState;
        [self didChangeValueForKey:NSStringFromSelector(@selector(cancelledState))];
        
        if (_cancelledState) {
            for (id<APOperationObserver> observer in _observers) {
                if ([observer respondsToSelector:@selector(operationDidCancel:)]) {
                    [observer operationDidCancel:self];
                }
            }
        }
    }
}

#pragma mark - Public

- (void)execute {
    [self finishWithErrors:nil];
    // To be implemented by subclasses
}

- (void)cancelWithErrors:(nullable NSArray<NSError *> *)errors {
    if (errors.count) {
        [_internalErrors addObjectsFromArray:errors];
    }
    [self cancel];
}

- (void)willEnqueue {
    // Indicates that the operation can now begin to evaluate readiness conditions, if appropriate
    self.state = APOperationStatePending;
}

- (void)addCondition:(id<APOperationCondition>)condition {
    NSAssert(self.state < APOperationStateEvaluatingConditions, @"Cannot modify conditions after execution has begun.");
    [_conditions addObject:condition];
}

- (void)addObserver:(id<APOperationObserver>)observer {
    NSAssert(self.state < APOperationStateEvaluatingConditions, @"Cannot modify observers after execution has begun.");
    [_observers addObject:observer];
}

- (void)addDependency:(NSOperation *)operation {
    NSAssert(self.state < APOperationStateExecuting, @"Dependencies cannot be modified after execution has begun.");
    [super addDependency:operation];
}

- (void)produceOperation:(NSOperation *)operation {
    for (id<APOperationObserver> observer in _observers) {
        if ([observer respondsToSelector:@selector(operation:didProduceOperation:)]) {
            [observer operation:self didProduceOperation:operation];
        }
    }
}

- (void)finishWithErrors:(nullable NSArray<NSError *> *)errors {
    if (!_hasFinishedAlready) {
        _hasFinishedAlready = YES;
        self.state = APOperationStateFinishing;
        
        if (!errors) {
            errors = [NSArray new];
        }
        NSArray<NSError *> *combinedErrors = [_internalErrors arrayByAddingObjectsFromArray:errors];
        [self finishedWithErrors:combinedErrors];
        
        for (id<APOperationObserver> observer in _observers) {
            if ([observer respondsToSelector:@selector(operationDidFinish:errors:)]) {
                [observer operationDidFinish:self errors:combinedErrors];
            }
        }
        
        self.state = APOperationStateFinished;
    }
}

- (void)finishedWithErrors:(nullable NSArray<NSError *> *)errors {
    // To be implemented by subclasses
}

#pragma mark - NSOperation

- (BOOL)isReady {
    // Here is where we extend our definition of "readiness"
    BOOL ready = NO;
    [_readyLock lock];
    switch (self.state) {
        case APOperationStateInitialized:
            ready = self.cancelled;
            break;
        case APOperationStatePending:
            if (self.cancelled) {
                self.state = APOperationStateReady;
                ready = YES;
                break;
            }
            
            if ([super isReady]) {
                [self _evaluateConditions];
            }
            
            ready = NO;
            break;
        case APOperationStateReady:
            ready = [super isReady] || self.cancelled;
            break;
        default:
            ready = NO;
            break;
    }
    
    [_readyLock unlock];
    return ready;
}

- (BOOL)isExecuting {
    return self.state == APOperationStateExecuting;
}

- (BOOL)isFinished {
    return self.state == APOperationStateFinished;
}

- (BOOL)isCancelled {
    return _cancelledState;
}

- (void)start {
    [super start];
    
    // If the operation has been cancelled, we still need to enter the "Finished" state
    if (self.cancelled) {
        [self finishWithErrors:nil];
    }
}

- (void)main {
    NSAssert(self.state == APOperationStateReady, @"This operation must be performed on an operation queue.");
    
    if (!_internalErrors.count && !self.cancelled) {
        self.state = APOperationStateExecuting;
        
        for (id<APOperationObserver> observer in _observers) {
            if ([observer respondsToSelector:@selector(operationDidStart:)]) {
                [observer operationDidStart:self];
            }
        }
        
        [self execute];
    } else {
        [self finishWithErrors:nil];
    }
}

- (void)cancel {
    if ([self isFinished]) {
        return;
    }
    
    self.cancelledState = YES;
    
    if (self.state > APOperationStateReady) {
        [self finishWithErrors:nil];
    }
}

- (void)waitUntilFinished {
    NSAssert(NO, @"Waiting on operations is an anti-pattern. Remove this ONLY if you're absolutely sure there is No Other Way™.");
}

#pragma mark - Internal

- (BOOL)_canTransitionToState:(APOperationState)state {
    APOperationState currentState = _state;
    if (currentState == APOperationStateInitialized && state == APOperationStatePending) {
        return YES;
    } else if (currentState == APOperationStatePending && state == APOperationStateEvaluatingConditions) {
        return YES;
    } else if (currentState == APOperationStatePending && state == APOperationStateReady && self.cancelled) {
        return YES;
    } else if (currentState == APOperationStatePending && state == APOperationStateFinishing && self.cancelled) {
        return YES;
    } else if (currentState == APOperationStateEvaluatingConditions && state == APOperationStateReady) {
        return YES;
    } else if (currentState == APOperationStateReady && state == APOperationStateExecuting) {
        return YES;
    } else if (currentState == APOperationStateReady && state == APOperationStateFinishing) {
        return YES;
    } else if (currentState == APOperationStateExecuting && state == APOperationStateFinishing) {
        return YES;
    } else if (currentState == APOperationStateFinishing && state == APOperationStateFinished) {
        return YES;
    }
    return NO;
}

- (void)_evaluateConditions {
    NSAssert(self.state == APOperationStatePending && !self.cancelled, @"evaluateConditions: was called out-of-order");
    self.state = APOperationStateEvaluatingConditions;
    
    [APOperationConditionEvaluator evaluateConditions:_conditions operation:self completion:^(NSArray<NSError *> * _Nullable errors) {
        if (errors.count) {
            [self cancelWithErrors:errors];
        }
        
        self.state = APOperationStateReady;
    }];
}

- (NSString *)_stringForState {
    switch (self.state) {
        case APOperationStateInitialized:
            return @"Initialized";
        case APOperationStatePending:
            return @"Pending";
        case APOperationStateEvaluatingConditions:
            return @"Evaluating Conditions";
        case APOperationStateReady:
            return @"Ready";
        case APOperationStateExecuting:
            return @"Executing";
        case APOperationStateFinishing:
            return @"Finishing";
        case APOperationStateFinished:
            return @"Finished";
        default:
            NSAssert(NO, @"Missing string for internal state");
            return @"Unknown";
    }
}

#pragma mark - NSKeyValueObserving

// Use the KVO mechanism to indicate that changes to "state" affect other properties as well

+ (NSSet *)keyPathsForValuesAffectingIsReady {
    return [NSSet setWithObject:NSStringFromSelector(@selector(state))];
}

+ (NSSet *)keyPathsForValuesAffectingIsExecuting {
    return [NSSet setWithObject:NSStringFromSelector(@selector(state))];
}

+ (NSSet *)keyPathsForValuesAffectingIsFinished {
    return [NSSet setWithObject:NSStringFromSelector(@selector(state))];
}

+ (NSSet *)keyPathsForValuesAffectingIsCancelled {
    return [NSSet setWithObject:NSStringFromSelector(@selector(cancelledState))];
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ state: %@>", NSStringFromClass([self class]), [self _stringForState]];
}

@end
