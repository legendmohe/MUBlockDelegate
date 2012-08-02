//
//  MUBlockDelegate.m
//  MUWork
//
//  Created by 何 新宇 on 12-7-30.
//  Copyright (c) 2012年 MUWork. All rights reserved.
//

#import "MUBlockDelegate.h"
#import <objc/runtime.h>

BOOL method_description_isNULL(struct objc_method_description desc)
{
    return (desc.types == NULL) && (desc.name == NULL);
}

const char * procure_encoding_string_for_selector_from_protocol(SEL sel, Protocol * protocol)
{
    static BOOL isReqVals[4] = {NO, NO, YES, YES};
    static BOOL isInstanceVals[4] = {NO, YES, NO, YES};
    struct objc_method_description desc = {NULL, NULL};
    for( int i = 0; i < 4; i++ ){
        desc = protocol_getMethodDescription(protocol,
                                             sel,
                                             isReqVals[i],
                                             isInstanceVals[i]);
        if( !method_description_isNULL(desc) ){
            break;
        }
    }
    
    return desc.types;
}

@interface MUBlockValueObject : NSObject

@property(nonatomic, copy) void(^block)(NSInvocation* anInvocation, NSArray* params);
@property(nonatomic, copy) NSString* selectorString;
@property(nonatomic, strong) NSMethodSignature* methodSignature;

@end

@implementation MUBlockValueObject

@synthesize selectorString, methodSignature, block;

@end

@interface MUBlockDelegate()

- (MUBlockValueObject*) valueObjectForSelectorString:(NSString*) selectorString;

@end

@implementation MUBlockDelegate

- (id) init
{
    self = [super init];
    if (self) {
        _SELBlockDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - methods

+ (MUBlockDelegate*) delegateForSelectorString:(NSString*) aSelectorString delegateBlock:(kMUBlockDelegateProxyBlock) aBlock
{
    if (aSelectorString == nil || aBlock == nil) {
        return nil;
    }
    
    MUBlockDelegate* aDelegate = [[MUBlockDelegate alloc] init];
    [aDelegate setSelectorString:aSelectorString forDelegateBlock:aBlock];
    
    return aDelegate;
}

+ (MUBlockDelegate*) delegateForClass:(Class) aClass selector:(SEL) aSelector delegateBlock:(kMUBlockDelegateProxyBlock) aBlock
{
    if (aClass == nil || aSelector == nil || aBlock == nil) {
        return nil;
    }
    
    
    MUBlockDelegate* aDelegate = [[MUBlockDelegate alloc] init];
    [aDelegate setClass:aClass selector:aSelector delegateBlock:aBlock];
    return aDelegate;
}

+ (MUBlockDelegate*) delegateForProtocol:(Protocol*) aProtocol selector:(SEL) aSelector delegateBlock:(kMUBlockDelegateProxyBlock) aBlock
{
    if (aProtocol == nil || aSelector == nil || aBlock == nil) {
        return nil;
    }
    
    
    MUBlockDelegate* aDelegate = [[MUBlockDelegate alloc] init];
    [aDelegate setProtocol:aProtocol selector:aSelector delegateBlock:aBlock];
    return aDelegate;
}

- (void) setSelectorString:(NSString*) aSelectorString forDelegateBlock:(kMUBlockDelegateProxyBlock) aBlock
{
    if (aSelectorString == nil || aBlock == nil) {
        return;
    }
    
    MUBlockValueObject* anValueObject = [self valueObjectForSelectorString:aSelectorString];
    anValueObject.block = aBlock;
    
    [_SELBlockDictionary setObject:anValueObject forKey:anValueObject.selectorString];
}

- (void) setClass:(Class) aClass selector:(SEL) aSelector delegateBlock:(kMUBlockDelegateProxyBlock) aBlock
{
    if (aClass == nil || aSelector == nil || aBlock == nil) {
        return;
    }
    
    NSMethodSignature* sig = [aClass instanceMethodSignatureForSelector:aSelector];
    
    if (sig) {
        MUBlockValueObject* anValueObject = [[MUBlockValueObject alloc] init];
        anValueObject.methodSignature = sig;
        anValueObject.selectorString = NSStringFromSelector(aSelector);
        anValueObject.block = aBlock;
        
        [_SELBlockDictionary setObject:anValueObject forKey:anValueObject.selectorString];
    }
}

- (void) setProtocol:(Protocol*) aProtocol selector:(SEL) aSelector delegateBlock:(kMUBlockDelegateProxyBlock) aBlock
{
    if (aProtocol == nil || aSelector == nil || aBlock == nil) {
        return;
    }
    
    NSMethodSignature* sig = [NSMethodSignature signatureWithObjCTypes:procure_encoding_string_for_selector_from_protocol(aSelector, aProtocol)];
    
    if (sig) {
        MUBlockValueObject* anValueObject = [[MUBlockValueObject alloc] init];
        anValueObject.methodSignature = sig;
        anValueObject.selectorString = NSStringFromSelector(aSelector);
        anValueObject.block = aBlock;
        
        [_SELBlockDictionary setObject:anValueObject forKey:anValueObject.selectorString];
    }
}

- (void) removeDelegateForSelector:(SEL) aSelector
{
    if (aSelector == nil) {
        return;
    }
    
    [_SELBlockDictionary removeObjectForKey:NSStringFromSelector(aSelector)];
}

#pragma mark - private

- (MUBlockValueObject*) valueObjectForSelectorString:(NSString*) selectorString
{
    MUBlockValueObject* anValueObject = [[MUBlockValueObject alloc] init];
    NSMutableString* aTypeString = [[NSMutableString alloc] init];
    NSMutableString* aSelectorString = [[NSMutableString alloc] init];
    
    [aTypeString appendString:[selectorString substringWithRange:NSMakeRange(1, 1)]];
    [aTypeString appendString:@"@:"];
    
    selectorString = [selectorString substringFromIndex:3];

    NSArray* argumentsNames = [selectorString componentsSeparatedByString:@")"];
    for (NSString* argmentName in argumentsNames) {
        
        if ([argmentName rangeOfString:@"("].location != NSNotFound) {
            
            [aTypeString appendString:[argmentName substringFromIndex:[argmentName length] - 1]];
            [aSelectorString appendString:[argmentName substringToIndex:[argmentName length] - 2]];
            [aSelectorString appendString:@":"];
            
        }else {
            [aSelectorString appendString:argmentName];
        }
    }

    anValueObject.selectorString = [NSString stringWithString:aSelectorString];
    anValueObject.methodSignature = [NSMethodSignature signatureWithObjCTypes:[aTypeString cStringUsingEncoding:NSUTF8StringEncoding]];
    
    return anValueObject;
}

#pragma mark - override

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    return YES;
}

- (BOOL)isKindOfClass:(Class)aClass
{
    return YES;
}

- (BOOL)isMemberOfClass:(Class)aClass
{
    return YES;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if (![NSObject instancesRespondToSelector:aSelector]
        && ![_SELBlockDictionary objectForKey:NSStringFromSelector(aSelector)]) {
        return NO;
    }else {
        return YES;
    }
}

- (NSMethodSignature*) methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature* aSignature = [super methodSignatureForSelector:aSelector];
    if (!aSignature) {
        
        MUBlockValueObject* aValueObject = [_SELBlockDictionary objectForKey:NSStringFromSelector(aSelector)];
        if (aValueObject) {
            return aValueObject.methodSignature;
        }
    }
    return aSignature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    MUBlockValueObject* aValueObject = [_SELBlockDictionary objectForKey:NSStringFromSelector(anInvocation.selector)];
    if (aValueObject) {
        NSMethodSignature* sig = [anInvocation methodSignature];
        NSMutableArray* anArray = [[NSMutableArray alloc] init];
        
        NSUInteger numberOfArgument = sig.numberOfArguments;
        for (NSUInteger i = 2; i < numberOfArgument; i++) {
            
            const char* argumentType = [sig getArgumentTypeAtIndex:i];
            if( !strcmp(argumentType, @encode(id)) ){
                id buffer;
                [anInvocation getArgument:&buffer atIndex:i];
                if (buffer) {
                    [anArray addObject:buffer];
                }
            }
            else {
                
                id anArgument = nil;
                
                if( !strcmp(argumentType, @encode(BOOL)) ) {
                    BOOL buffer = NO;
                    [anInvocation getArgument:&buffer atIndex:i];
                    anArgument = [NSNumber numberWithBool:buffer];
                }
                else if( !strcmp(argumentType, @encode(NSInteger)) ){
                    NSInteger buffer = 0;
                    [anInvocation getArgument:&buffer atIndex:i];
                    anArgument = [NSNumber numberWithInteger:buffer];
                }
                else if( !strcmp(argumentType, @encode(NSUInteger)) ){
                    NSUInteger buffer = 0;
                    [anInvocation getArgument:&buffer atIndex:i];
                    anArgument = [NSNumber numberWithInteger:buffer];
                }
                else if( !strcmp(argumentType, @encode(float)) ){
                    float buffer = 0;
                    [anInvocation getArgument:&buffer atIndex:i];
                    anArgument = [NSNumber numberWithFloat:buffer];
                }
                else if( !strcmp(argumentType, @encode(char)) ){
                    char buffer = 0;
                    [anInvocation getArgument:&buffer atIndex:i];
                    anArgument = [NSNumber numberWithChar:buffer];
                }
                else if( !strcmp(argumentType, @encode(double)) ){
                    double buffer = 0;
                    [anInvocation getArgument:&buffer atIndex:i];
                    anArgument = [NSNumber numberWithDouble:buffer];
                }
                else if( !strcmp(argumentType, @encode(int)) ){
                    int buffer = 0;
                    [anInvocation getArgument:&buffer atIndex:i];
                    anArgument = [NSNumber numberWithInt:buffer];
                }
                else if( !strcmp(argumentType, @encode(long)) ){
                    long buffer = 0;
                    [anInvocation getArgument:&buffer atIndex:i];
                    anArgument = [NSNumber numberWithLong:buffer];
                }
                else if( !strcmp(argumentType, @encode(long long)) ){
                    long long buffer = 0;
                    [anInvocation getArgument:&buffer atIndex:i];
                    anArgument = [NSNumber numberWithLongLong:buffer];
                }
                else if( !strcmp(argumentType, @encode(short)) ){
                    short buffer = 0;
                    [anInvocation getArgument:&buffer atIndex:i];
                    anArgument = [NSNumber numberWithShort:buffer];
                }
                else{
                    void *buffer = NULL;
                    [anInvocation getArgument:&buffer atIndex:i];
                    anArgument = [NSValue valueWithBytes:buffer objCType:argumentType];
                }
                
                [anArray addObject:anArgument];
            }
        }
        
        aValueObject.block(anInvocation, anArray);
    }else {
        [super forwardInvocation:anInvocation];
    }
}

@end
