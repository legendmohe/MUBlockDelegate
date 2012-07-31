//
//  MUBlockDelegate.h
//  MUWork
//
//  Created by 何 新宇 on 12-7-30.
//  Copyright (c) 2012年 MUWork. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMUBlockDelegateProxyBlock void(^)(NSInvocation* anInvocation, NSArray* params)

@interface MUBlockDelegate : NSObject {
    NSMutableDictionary* _SELBlockDictionary;
}

//for example: (@)doSomething(@)withObject(@)forTimes(i) == - (id)doSomething:(id) something withObject:(id) anObject forTimes:(NSInteger) times
//"@","i" are objCTypes which can be decode by @encode(NSString) and @encode(NSInteger)
+ (MUBlockDelegate*) delegateForSelectorString:(NSString*) aSelectorString delegateBlock:(kMUBlockDelegateProxyBlock) aBlock;
+ (MUBlockDelegate*) delegateForClass:(Class) aClass selector:(SEL) aSelector delegateBlock:(kMUBlockDelegateProxyBlock) aBlock;
+ (MUBlockDelegate*) delegateForProtocol:(Protocol*) aProtocol selector:(SEL) aSelector delegateBlock:(kMUBlockDelegateProxyBlock) aBlock;

- (void) setSelectorString:(NSString*) aSelectorString forDelegateBlock:(kMUBlockDelegateProxyBlock) aBlock;

- (void) setClass:(Class) aClass selector:(SEL) aSelector delegateBlock:(kMUBlockDelegateProxyBlock) aBlock;

- (void) setProtocol:(Protocol*) aProtocol selector:(SEL) aSelector delegateBlock:(kMUBlockDelegateProxyBlock) aBlock;

@end
