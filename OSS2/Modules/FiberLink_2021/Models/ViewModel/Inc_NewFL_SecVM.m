//
//  Inc_NewFL_SecVM.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/10/22.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_NewFL_SecVM.h"

@implementation Inc_NewFL_SecVM

#pragma mark - 声明单粒 ---

+ (Inc_NewFL_SecVM *) shareInstance {
    
    static Inc_NewFL_SecVM * instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[super alloc] init];
    });
    
    return instance;
}


- (id) copyWithZone:(NSZone *) zone {
    
    return  [self.class shareInstance];
}

- (id) mutableCopyWithZone:(NSZone *) zone {
    
    return  [self.class shareInstance];
}

@end
