//
//  Inc_PoleNC_ViewModel.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/9/7.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_PoleNC_ViewModel.h"

@implementation Inc_PoleNC_ViewModel

#pragma mark - 声明单粒 ---

+ (Inc_PoleNC_ViewModel *) shareInstance {
    
    static Inc_PoleNC_ViewModel * instance = nil;
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
