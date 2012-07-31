//
//  TestObject.m
//  MUBlockDelegate
//
//  Created by 何 新宇 on 12-7-31.
//  Copyright (c) 2012年 MUWork. All rights reserved.
//

#import "TestObject.h"

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
