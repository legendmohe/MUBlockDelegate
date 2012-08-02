//
//  MUBlockDelegateTests.m
//  MUBlockDelegateTests
//
//  Created by 何 新宇 on 12-7-31.
//  Copyright (c) 2012年 MUWork. All rights reserved.
//

#import "MUBlockDelegateTests.h"
#import "MUBlockDelegate.h"

#import "TestProtcol.h"
#import "TestObject.h"
#import "TestDelegateImpl.h"

@implementation MUBlockDelegateTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testNormal {
    
    TestDelegateImpl* testDelegate = [[TestDelegateImpl alloc] init];
    TestObject* testObject = [[TestObject alloc] init];
    testObject.delegate = testDelegate;
    
    NSLog(@"testResult:%@", [testObject callDelegate:@"testNormal"]);
}

- (void)testBlock {
    MUBlockDelegate* testDelegate = [MUBlockDelegate delegateForSelectorString:@"(@)testDelegateMethod(@)" delegateBlock:^(NSInvocation *anInvocation, NSArray *params) {
        
        NSString* testString = [params objectAtIndex:0];
        [anInvocation setReturnValue:&testString];
    }];
    
    TestObject* testObject = [[TestObject alloc] init];
    testObject.delegate = (id<TestProtcol>)testDelegate;
    
    NSString* testResult = [testObject callDelegate:@"testBlock"];
    NSLog(@"testResult:%@", testResult);
}

- (void)testClassBlock {
    MUBlockDelegate* testDelegate = [MUBlockDelegate delegateForClass:[TestDelegateImpl class] selector:@selector(testDelegateMethod:) delegateBlock:^(NSInvocation *anInvocation, NSArray *params) {
        
        NSString* testString = [params objectAtIndex:0];
        [anInvocation setReturnValue:&testString];
    }];
    
    TestObject* testObject = [[TestObject alloc] init];
    testObject.delegate = (id<TestProtcol>)testDelegate;
    
    NSString* testResult = [testObject callDelegate:@"testClassBlock"];
    NSLog(@"testResult:%@", testResult);
}

- (void)testProtocolBlock {
    MUBlockDelegate* testDelegate = [MUBlockDelegate delegateForProtocol:@protocol(TestProtcol) selector:@selector(testDelegateMethod:) delegateBlock:^void(NSInvocation* anInvocation, NSArray *params) {
        NSLog(@"params:%@", anInvocation);
        
        NSString* testString = [params objectAtIndex:0];
        [anInvocation setReturnValue:&testString];
    }];
    
    TestObject* testObject = [[TestObject alloc] init];
    testObject.delegate = (id<TestProtcol>)testDelegate;
    
    NSString* testResult = [testObject callDelegate:@"testProtocolBlock"];
    NSLog(@"testResult:%@", testResult);
}

@end
