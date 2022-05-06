//
//  Inc_UserModel.m
//  javaScript_ObjectC
//
//  Created by yuanquan on 2022/4/19.
//

#import "Inc_UserModel.h"

@implementation Inc_UserModel

/// 对用户信息赋值
- (void) userModelConfig:(NSDictionary *) dict {
    
    _userInfo = dict;
    
    if ([dict.allKeys containsObject:@"UID"]) {
        _uid = [dict objectForKey:@"UID"];
    }
    
    if ([dict.allKeys containsObject:@"areano"]) {
        _areano = dict[@"areano"];
        _domainCode = [[dict[@"areano"] substringWithRange:NSMakeRange(0, 2)] stringByAppendingString:@"/"];
        _areaName = dict[@"areaName"];
    }
      
}



/// 对用户权限进行缓存
- (void) userPowerConfig:(NSDictionary *) dict {
    
    NSString * powers1 = dict[@"powers1"];
    NSString * powers2 = dict[@"powers2"];
    
    _powersDic = [powers1.object object];
    _powersTYKDic = [powers2.object object];
    
    
    NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:_userInfo];
    mt_Dict[@"powers1"] = _powersDic;
    mt_Dict[@"powers2"] = _powersTYKDic;
    
    _userInfo = mt_Dict;
    
}



#pragma mark - 声明单粒 ---

+ (Inc_UserModel *) shareInstance {
    
    static Inc_UserModel * instance = nil;
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
