MUBlockDelegate
============

1.normally, we use delegates as follows:
   
   firstly,
   
    @protocol TestProtcol <NSObject>

    - (NSString*) testDelegateMethod:(NSString*) aString;

    @end

    @interface TestDelegateImpl : NSObject<TestProtcol>

    @end

    and：

    @implementation TestDelegateImpl

    - (NSString*) testDelegateMethod:(NSString *)aString
    {
        return aString;
    }

    @end
    
    secondly,
    
    #import "TestProtcol.h"

    @interface TestObject : NSObject

    @property(nonatomic, weak) id<TestProtcol> delegate;

    - (NSString*) callDelegate:(NSString*) aString;

    @end
    
    @implementation TestObject

    @synthesize delegate = _delegate;

    - (NSString*) callDelegate:(NSString*) aString
    {
        if ([_delegate respondsToSelector:@selector(testDelegateMethod:)]) {
            return [_delegate testDelegateMethod:aString];
        }
        
        return nil;
    }

    @end
    
    at last, we do some tests:
    
    TestDelegateImpl* testDelegate = [[TestDelegateImpl alloc] init];
    TestObject* testObject = [[TestObject alloc] init];
    testObject.delegate = testDelegate;
    
    NSLog(@"result:%@", [testObject callDelegate:@"testNormal"]);
    
2.if you use MUBlockDelegate:

    firstly,
    
    MUBlockDelegate* testDelegate = [MUBlockDelegate delegateForSelectorString:@"(@)testDelegateMethod(@)" delegateBlock:^(NSInvocation *anInvocation, NSArray *params) {
        
        NSString* testString = [params objectAtIndex:0];
        [anInvocation setReturnValue:&testString];
    }];
    
    then, do some tests,
    
    TestObject* testObject = [[TestObject alloc] init];
    testObject.delegate = (id<TestProtcol>)testDelegate;
    
    NSString* testResult = [testObject callDelegate:@"testBlock"];
    NSLog(@"testResult:%@", testResult);
    
    that's all.
    
    the other approach:
    
    MUBlockDelegate* testDelegate = [MUBlockDelegate delegateForClass:[TestDelegateImpl class] selector:@selector(testDelegateMethod:) delegateBlock:^(NSInvocation *anInvocation, NSArray *params) {
        
        NSString* testString = [params objectAtIndex:0];
        [anInvocation setReturnValue:&testString];
    }];
    
    MUBlockDelegate* testDelegate = [MUBlockDelegate delegateForProtocol:@protocol(TestProtcol) selector:@selector(testDelegateMethod:) delegateBlock:^void(NSInvocation* anInvocation, NSArray *params) {
        NSLog(@"params:%@", anInvocation);
        
        NSString* testString = [params objectAtIndex:0];
        [anInvocation setReturnValue:&testString];
    }];
    
    do the same thing.
    
3.run the TESTCASE
    