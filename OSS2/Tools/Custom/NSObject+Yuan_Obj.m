//
//  NSObject+Yuan_Obj.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/11/17.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "NSObject+Yuan_Obj.h"




@implementation NSObject (Yuan_Obj)


- (BOOL) obj_IsNull {
    
    if ([self isEqual:[NSNull null]] || !self) {
        return YES;
    }
    
    return NO;
}

@end
