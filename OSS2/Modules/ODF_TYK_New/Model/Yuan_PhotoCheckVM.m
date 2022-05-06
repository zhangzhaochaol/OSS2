//
//  Yuan_PhotoCheckVM.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/2.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_PhotoCheckVM.h"

@implementation Yuan_PhotoCheckVM

#pragma mark - 声明单粒 ---

+ (Yuan_PhotoCheckVM *) shareInstance {
    
    static Yuan_PhotoCheckVM * instance = nil;
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
