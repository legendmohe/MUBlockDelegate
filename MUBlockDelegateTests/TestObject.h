//
//  TestObject.h
//  MUBlockDelegate
//
//  Created by 何 新宇 on 12-7-31.
//  Copyright (c) 2012年 MUWork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TestProtcol.h"

@interface TestObject : NSObject

@property(nonatomic, weak) id<TestProtcol> delegate;

- (NSString*) callDelegate:(NSString*) aString;

@end
