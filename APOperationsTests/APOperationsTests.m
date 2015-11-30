//
//  APOperationsTests.m
//  APOperationsTests
//
//  Created by Alex Perez on 11/26/15.
//  Copyright © 2015 Alex Perez. All rights reserved.
//

@import XCTest;

#import "APTestCondition.h"
#import "APTestObserver.h"
#import "APWaitOperation.h"

#import <APOperations/APOperations.h>

@interface APOperationsTests : XCTestCase

@end

@implementation APOperationsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddingMultipleDeps {
    NSOperation *operation = [NSOperation new];
    NSArray<NSOperation *> *dependencies = @[[NSOperation new], [NSOperation new], [NSOperation new]];
    [operation ap_addDependencies:dependencies];
    XCTAssertEqual(dependencies.count, operation.dependencies.count);
}

- (void)testStandardOperation {
    XCTestExpectation *expectation = [self expectationWithDescription:@"block"];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        [expectation fulfill];
    }];
    [operationQueue addOperation:blockOperation];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testBlockOperation_noConditions_noDependencies {
    XCTestExpectation *expectation = [self expectationWithDescription:@"block"];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    APBlockOperation *blockOperation = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation) {
        [expectation fulfill];
    }];
    [operationQueue addOperation:blockOperation];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testOperation_withPassingCondition_noDependencies {
    XCTestExpectation *expectation = [self expectationWithDescription:@"block"];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    APBlockOperation *blockOperation = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation) {
        [expectation fulfill];
    }];
    [blockOperation addCondition:[APTestCondition new]];
    [operationQueue addOperation:blockOperation];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testOperation_withFailingCondition_noDependencies {
    APOperationQueue *operationQueue = [APOperationQueue new];
    APBlockOperation *blockOperation = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation) {
        XCTFail(@"Should not have run the block operation");
    }];
    
    [self keyValueObservingExpectationForObject:blockOperation keyPath:NSStringFromSelector(@selector(isCancelled)) handler:^BOOL(NSOperation * _Nonnull operation, NSDictionary * _Nonnull change) {
        return operation.cancelled;
    }];
    
    XCTAssertFalse(blockOperation.cancelled, @"Should not yet have cancelled the operation");
    
    APTestCondition *testCondition = [APTestCondition new];
    testCondition.conditionBlock = ^BOOL{
        return NO;
    };
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"observer"];
    
    APTestObserver *testObserver = [APTestObserver new];
    __weak typeof(APTestObserver) *weakTestObserver = testObserver;
    testObserver.didEndBlock = ^{
        XCTAssertEqual(weakTestObserver.errors.count, 1);
        [expectation fulfill];
    };
    
    [blockOperation addCondition:testCondition];
    [blockOperation addObserver:testObserver];
    [operationQueue addOperation:blockOperation];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testOperation_withPassingCondition_andConditionDependency_noDependencies {
    XCTestExpectation *expectation1 = [self expectationWithDescription:@"block1"];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"block2"];
    NSMutableArray<XCTestExpectation *> *fulfilledExpectations = [NSMutableArray new];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    APBlockOperation *blockOperation = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation) {
        [expectation1 fulfill];
        [fulfilledExpectations addObject:expectation1];
    }];
    
    APTestCondition *testCondition = [APTestCondition new];
    testCondition.dependencyOperation = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation) {
        [expectation2 fulfill];
        [fulfilledExpectations addObject:expectation2];
    }];
    
    [blockOperation addCondition:testCondition];
    [operationQueue addOperation:blockOperation];
    
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError * _Nullable error) {
        NSArray<XCTestExpectation *> *expectedExpectations = @[expectation2, expectation1];
        NSLog(@"%@\n%@",fulfilledExpectations, expectedExpectations);
        XCTAssertEqualObjects(fulfilledExpectations, expectedExpectations, @"Expectations fulfilled out of order");
    }];
}

- (void)testOperation_noCondition_hasDependency {
    XCTestExpectation *expectation = [self expectationWithDescription:@"block1"];
    XCTestExpectation *expectationDependency = [self expectationWithDescription:@"block2"];
    NSMutableArray<XCTestExpectation *> *fulfilledExpectations = [NSMutableArray new];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    APBlockOperation *blockOperation = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation) {
        [expectation fulfill];
        [fulfilledExpectations addObject:expectation];
    }];
    
    APBlockOperation *operationDependency = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation) {
        [expectationDependency fulfill];
        [fulfilledExpectations addObject:expectationDependency];
    }];
    
    [blockOperation addDependency:operationDependency];
    
    [operationQueue addOperation:blockOperation];
    [operationQueue addOperation:operationDependency];
    
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError * _Nullable error) {
        NSArray<XCTestExpectation *> *expectedExpectations = @[expectationDependency, expectation];
        XCTAssertEqualObjects(fulfilledExpectations, expectedExpectations, @"Expectations fulfilled out of order");
    }];
}

- (void)testGroupOperation {
    XCTestExpectation *expectation1 = [self expectationWithDescription:@"block1"];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"block2"];
    
    NSOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        [expectation1 fulfill];
    }];
    
    NSOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        [expectation2 fulfill];
    }];
    
    APGroupOperation *groupOperation = [[APGroupOperation alloc] initWithOperatons:@[operation1, operation2]];
    
    [self keyValueObservingExpectationForObject:groupOperation keyPath:NSStringFromSelector(@selector(isFinished)) handler:^BOOL(NSOperation * _Nonnull operation, NSDictionary * _Nonnull change) {
        return operation.finished;
    }];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    [operationQueue addOperation:groupOperation];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testGroupOperation_cancelBeforeExecuting {
    XCTestExpectation *expectation1 = [self expectationWithDescription:@"block1"];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"block2"];
    
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        XCTFail("should not execute -- cancelled");
    }];
    operation1.completionBlock = ^{
        [expectation1 fulfill];
    };
    
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        XCTFail("should not execute -- cancelled");
    }];
    operation2.completionBlock = ^{
        [expectation2 fulfill];
    };
    
    APGroupOperation *groupOperation = [[APGroupOperation alloc] initWithOperatons:@[operation1, operation2]];
    
    [self keyValueObservingExpectationForObject:groupOperation keyPath:NSStringFromSelector(@selector(isFinished)) handler:^BOOL(NSOperation * _Nonnull operation, NSDictionary * _Nonnull change) {
        return operation.finished;
    }];
    
    [self keyValueObservingExpectationForObject:operation1 keyPath:NSStringFromSelector(@selector(isFinished)) handler:^BOOL(NSOperation * _Nonnull operation, NSDictionary * _Nonnull change) {
        return YES;
    }];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    operationQueue.suspended = YES;
    [operationQueue addOperation:groupOperation];
    [groupOperation cancel];
    operationQueue.suspended = NO;
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testDelayOperation {
    NSTimeInterval delay = 0.1;
    NSDate *then = [NSDate new];
    
    NSOperation *delayOperation = [[APDelayOperation alloc] initWithTimeInterval:delay];
    [self keyValueObservingExpectationForObject:delayOperation keyPath:NSStringFromSelector(@selector(isFinished)) handler:^BOOL(NSOperation * _Nonnull operation, NSDictionary * _Nonnull change) {
        return operation.finished;
    }];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    [operationQueue addOperation:delayOperation];
    
    [self waitForExpectationsWithTimeout:delay + 1 handler:^(NSError * _Nullable error) {
        NSDate *now = [NSDate new];
        NSTimeInterval diff = [now timeIntervalSinceDate:then];
        XCTAssertTrue(diff >= delay, "Didn't delay long enough");
    }];
}

- (void)testDelayOperation_With0 {
    NSTimeInterval delay = 0.0;
    NSDate *then = [NSDate new];
    
    NSOperation *delayOperation = [[APDelayOperation alloc] initWithTimeInterval:delay];
    [self keyValueObservingExpectationForObject:delayOperation keyPath:NSStringFromSelector(@selector(isFinished)) handler:^BOOL(NSOperation * _Nonnull operation, NSDictionary * _Nonnull change) {
        return operation.finished;
    }];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    [operationQueue addOperation:delayOperation];
    
    [self waitForExpectationsWithTimeout:delay + 1 handler:^(NSError * _Nullable error) {
        NSDate *now = [NSDate new];
        NSTimeInterval diff = [now timeIntervalSinceDate:then];
        XCTAssertTrue(diff >= delay, "Didn't delay long enough");
    }];
}

- (void)testDelayOperation_WithDate {
    NSTimeInterval delay = 1.0;
    NSDate *date = [[NSDate new] dateByAddingTimeInterval:delay];
    NSDate *then = [NSDate new];
    
    NSOperation *delayOperation = [[APDelayOperation alloc] initWithUntilDate:date];
    [self keyValueObservingExpectationForObject:delayOperation keyPath:NSStringFromSelector(@selector(isFinished)) handler:^BOOL(NSOperation * _Nonnull operation, NSDictionary * _Nonnull change) {
        return operation.finished;
    }];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    [operationQueue addOperation:delayOperation];
    
    [self waitForExpectationsWithTimeout:delay + 1 handler:^(NSError * _Nullable error) {
        NSDate *now = [NSDate new];
        NSTimeInterval diff = [now timeIntervalSinceDate:then];
        XCTAssertTrue(diff >= delay, "Didn't delay long enough");
    }];
}

- (void)testMutualExclusion {
    APMutuallyExclusiveCondition *exclusiveCondition = [APMutuallyExclusiveCondition conditionWithType:@"TestMutualExclusion"];
    
    __block BOOL running = NO;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"block"];
    
    APBlockOperation *blockOperation = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation) {
        running = YES;
        [expectation fulfill];
    }];
    [blockOperation addCondition:exclusiveCondition];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    operationQueue.maxConcurrentOperationCount = 2;
    
    APOperation *delayOperation = [[APDelayOperation alloc] initWithTimeInterval:0.1];
    [delayOperation addCondition:exclusiveCondition];
    
    [self keyValueObservingExpectationForObject:delayOperation keyPath:NSStringFromSelector(@selector(isFinished)) handler:^BOOL(NSOperation * _Nonnull operation, NSDictionary * _Nonnull change) {
        XCTAssertFalse(running, "op should not yet have started execution");
        return operation.finished;
    }];
    
    [operationQueue addOperation:delayOperation];
    [operationQueue addOperation:blockOperation];
    
    [self waitForExpectationsWithTimeout:0.9 handler:nil];
}

- (void)testConditionObserversCalled {
    XCTestExpectation *startExpectation = [self expectationWithDescription:@"start"];
    XCTestExpectation *cancelExpectation = [self expectationWithDescription:@"cancel"];
    XCTestExpectation *produceExpectation = [self expectationWithDescription:@"produce"];
    XCTestExpectation *finishExpectation = [self expectationWithDescription:@"finish"];
    
    __block APBlockOperation *blockOperation = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation) {
        [blockOperation produceOperation:[APBlockOperation mainQueueBlock:^{}]];
        [blockOperation cancel];
    }];
    APBlockObserver *blockObserver = [[APBlockObserver alloc] initWithStartHandler:^(APOperation * _Nonnull operation) {
        [startExpectation fulfill];
    } cancelHandler:^(APOperation * _Nonnull operation) {
        [cancelExpectation fulfill];
    } produceHandler:^(APOperation * _Nonnull operation, NSOperation * _Nonnull newOperation) {
        [produceExpectation fulfill];
    } finishHandler:^(APOperation * _Nonnull operation, NSArray<NSError *> * _Nonnull errors) {
        [finishExpectation fulfill];
    }];
    [blockOperation addObserver:blockObserver];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    [operationQueue addOperation:blockOperation];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testSilentCondition_failure {
    // TODO: Implement APSilentCondition
}

- (void)testNegateCondition_failure {
    // TODO: Implement APNegateCondition
}

- (void)testNegateCondition_success {
    // TODO: Implement APNegateCondition
}

- (void)testNoCancelledDepsCondition_aDepCancels {
    // TODO: Implement APNoCancelledDependencies
}

- (void)testOperationRunsEvenIfDepCancels {
    NSOperation *dependencyOperation = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation){}];
    XCTestExpectation *expectation = [self expectationWithDescription:@"block"];
    
    NSOperation *blockOperation = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation) {
        [expectation fulfill];
    }];
    [blockOperation addDependency:dependencyOperation];
    
    [self keyValueObservingExpectationForObject:dependencyOperation keyPath:NSStringFromSelector(@selector(isCancelled)) handler:^BOOL(NSOperation * _Nonnull operation, NSDictionary * _Nonnull change) {
        return operation.cancelled;
    }];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    [operationQueue addOperation:blockOperation];
    [operationQueue addOperation:dependencyOperation];
    [dependencyOperation cancel];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testCancelledOperationLeavesQueue {
    XCTestExpectation *expectation = [self expectationWithDescription:@"block2"];
    
    NSOperation *blockOperation = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation){}];
    NSOperation *blockOperation2 = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation) {
        [expectation fulfill];
    }];
    
    [self keyValueObservingExpectationForObject:blockOperation keyPath:NSStringFromSelector(@selector(isCancelled)) handler:^BOOL(NSOperation * _Nonnull operation, NSDictionary * _Nonnull change) {
        return operation.cancelled;
    }];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    [operationQueue addOperation:blockOperation];
    [operationQueue addOperation:blockOperation2];
    [blockOperation cancel];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testCancelOperation_cancelBeforeStart {
    NSOperation *blockOperation = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation) {
        XCTFail("This should not run");
    }];
    
    [self keyValueObservingExpectationForObject:blockOperation keyPath:NSStringFromSelector(@selector(isFinished)) handler:^BOOL(NSOperation * _Nonnull operation, NSDictionary * _Nonnull change) {
        return operation.finished;
    }];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    operationQueue.suspended = YES;
    [operationQueue addOperation:blockOperation];
    [blockOperation cancel];
    operationQueue.suspended = NO;
    
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError * _Nullable error) {
        XCTAssertTrue(blockOperation.cancelled, "");
        XCTAssertTrue(blockOperation.finished, "");
    }];
}

- (void)testCancelOperation_cancelAfterStart {
    XCTestExpectation *expectation = [self expectationWithDescription:@"block"];
    
    NSOperation *blockOperation = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation) {
        [blockOperation cancel];
        [expectation fulfill];
    }];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    [operationQueue addOperation:blockOperation];
    
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError * _Nullable error) {
        XCTAssertEqual(operationQueue.operationCount, 0, "");
    }];
}

- (void)testBlockObserver {
    __block APBlockOperation *blockOperation = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation) {
        APBlockOperation *producedOperation = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation){}];
        [blockOperation produceOperation:producedOperation];
    }];
    
    XCTestExpectation *expectation1 = [self expectationWithDescription:@"start"];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"produce"];
    XCTestExpectation *expectation3 = [self expectationWithDescription:@"finish"];
    
    APBlockObserver *blockObserver = [[APBlockObserver alloc] initWithStartHandler:^(APOperation * _Nonnull operation) {
        [expectation1 fulfill];
    } cancelHandler:NULL produceHandler:^(APOperation * _Nonnull operation, NSOperation * _Nonnull newOperation) {
        [expectation2 fulfill];
    } finishHandler:^(APOperation * _Nonnull operation, NSArray<NSError *> * _Nonnull errors) {
        [expectation3 fulfill];
    }];
    
    [blockOperation addObserver:blockObserver];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    [operationQueue addOperation:blockOperation];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testTimeoutObserver {
    APDelayOperation *delayOperation = [[APDelayOperation alloc] initWithTimeInterval:1.0];
    APTimeoutObserver *timeoutObserver = [[APTimeoutObserver alloc] initWithTimeout:0.1];
    [delayOperation addObserver:timeoutObserver];
    
    [self keyValueObservingExpectationForObject:delayOperation keyPath:NSStringFromSelector(@selector(isCancelled)) handler:^BOOL(NSOperation * _Nonnull operation, NSDictionary * _Nonnull change) {
        return operation.cancelled;
    }];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    [operationQueue addOperation:delayOperation];
    
    [self waitForExpectationsWithTimeout:0.9 handler:nil];
}

- (void)testNoCancelledDepsCondition_aDepCancels_inGroupOperation {
    // TODO: Implement APNoCancelledDependencies
}

- (void)testOperationCompletionBlock {
    XCTestExpectation *executingExpectation = [self expectationWithDescription:@"block"];
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"completion"];
    
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        [executingExpectation fulfill];
    }];
    blockOperation.completionBlock = ^{
        [completionExpectation fulfill];
    };
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    [operationQueue addOperation:blockOperation];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testBlockOperationCanBeCancelledWhileExecuting {
    XCTestExpectation *expectation = [self expectationWithDescription:@"block"];
    
    __block APBlockOperation *blockOperation = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation) {
        XCTAssertFalse(blockOperation.finished);
        [blockOperation cancel];
        [expectation fulfill];
    }];
    
    [self keyValueObservingExpectationForObject:blockOperation keyPath:NSStringFromSelector(@selector(isCancelled)) handler:^BOOL(NSOperation * _Nonnull operation, NSDictionary * _Nonnull change) {
        return operation.cancelled;
    }];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    [operationQueue addOperation:blockOperation];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testDelayOperationIsCancellableAndNotFinishedTillDelayTime {
    XCTestExpectation *expectation = [self expectationWithDescription:@"block"];
    
    APDelayOperation *delayOperation = [[APDelayOperation alloc] initWithTimeInterval:2.0];
    APBlockOperation *blockOperation = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation) {
        XCTAssertFalse(delayOperation.finished);
        [delayOperation cancel];
        [expectation fulfill];
    }];
    
    [self keyValueObservingExpectationForObject:delayOperation keyPath:NSStringFromSelector(@selector(isCancelled)) handler:^BOOL(NSOperation * _Nonnull operation, NSDictionary * _Nonnull change) {
        return operation.cancelled;
    }];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    [operationQueue addOperation:delayOperation];
    [operationQueue addOperation:blockOperation];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testConcurrentOpsWithBlockingOp {
    XCTestExpectation *expectation = [self expectationWithDescription:@"block"];
    
    APDelayOperation *delayOperation = [[APDelayOperation alloc] initWithTimeInterval:4.0];
    APBlockOperation *blockOperation = [APBlockOperation blockOperationWithBlock:^(APBlockOperationContinuation _Nonnull continuation) {
        [expectation fulfill];
    }];
    
    APTimeoutObserver *timeoutObserver = [[APTimeoutObserver alloc] initWithTimeout:2.0];
    [blockOperation addObserver:timeoutObserver];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    [operationQueue addOperation:delayOperation];
    [operationQueue addOperation:blockOperation];
    
    [self keyValueObservingExpectationForObject:operationQueue keyPath:NSStringFromSelector(@selector(operationCount)) handler:^BOOL(NSOperationQueue * _Nonnull queue, NSDictionary * _Nonnull change) {
        if (queue && queue.operationCount == 1) {
            if ([queue.operations.firstObject isKindOfClass:[APDelayOperation class]]) {
                return YES;
            }
        }
        return NO;
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testMoveFromPendingToFinishingByWayOfCancelAfterEnteringQueue {
    NSOperation *operation = [NSOperation new];
    APDelayOperation *delayOperation = [[APDelayOperation alloc] initWithTimeInterval:0.1];
    [operation addDependency:delayOperation];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    [operationQueue addOperation:operation];
    [operationQueue addOperation:delayOperation];
    [operation cancel];
    
    [self keyValueObservingExpectationForObject:operationQueue keyPath:NSStringFromSelector(@selector(operationCount)) handler:^BOOL(NSOperationQueue * _Nonnull queue, NSDictionary * _Nonnull change) {
        return (queue.operationCount == 0);
    }];
    
    [self waitForExpectationsWithTimeout:0.5 handler:nil];
}

- (void)testOperationQueueWaitUntilFinished {
    APWaitOperation *waitOperation = [APWaitOperation new];
    
    APOperationQueue *operationQueue = [APOperationQueue new];
    [operationQueue addOperations:@[waitOperation] waitUntilFinished:YES];
    
    XCTAssertEqual(1, operationQueue.operationCount);
    XCTAssertTrue(waitOperation.waitCalled);
}

@end
