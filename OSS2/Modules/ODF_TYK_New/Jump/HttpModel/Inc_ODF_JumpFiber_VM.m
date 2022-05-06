//
//  Inc_ODF_JumpFiber_VM.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/6/24.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_ODF_JumpFiber_VM.h"

#import "Inc_ODF_JumpFiber_HttpModel.h"


@implementation Inc_ODF_JumpFiber_VM



/// 对 A端和Z端进行组合
- (void) combinationJumpFiber {
    
    if (_jumpFiber_Arr.count != 2) {
        [YuanHUD HUDFullText:@"数据错误"];
        return;
    }
    NSDictionary *topDic = _jumpFiber_Arr.firstObject;
    NSDictionary *bottomDic = _jumpFiber_Arr.lastObject;
    
    // 进行网络请求
    NSDictionary *pram = @{
        @"resType": @"optLine",
        @"datas":@[
                @{
                    @"aId": topDic[@"GID"],
                    @"zId": bottomDic[@"GID"],
                    @"aTypeId":@"317",
                    @"zTypeId":@"317",
                    @"aNo": topDic[@"termNo"],
                    @"zNo":bottomDic[@"termNo"],
                    @"aEqpTypeId": [self eqpIdType:topDic[@"eqpId_Type"]],
                    @"aEqpId": topDic[@"eqpId_Id"],
                    @"zEqpTypeId": [self eqpIdType:bottomDic[@"eqpId_Type"]],
                    @"zEqpId": bottomDic[@"eqpId_Id"],
                    @"linkType":@"0"
                }
        ]
    };
    

    
    [self AddUnionTermJump:pram];
    
 
  
}


/// 对 A端和Z端进行解除
- (void) relieveJumpFiber:(NSString *)gid {
    
  
    // 进行网络请求
    NSDictionary *pram = @{
        @"resType": @"optLine",
        @"datas":@[
                @{
                    @"gid":gid
                }
        ]
    };
    

    
    [self DeleteUnionTermJump:pram];
    
}
//- (void) clearDatas {
//
//    [_jumpFiber_Arr removeAllObjects];
//}


#pragma mark - 声明单粒 ---

+ (Inc_ODF_JumpFiber_VM *) shareInstance {
    
    static Inc_ODF_JumpFiber_VM * instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[super alloc] init];
    });
    
    return instance;
}

#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        _jumpFiber_Arr = NSMutableArray.array;
    }
    return self;
}


- (id) copyWithZone:(NSZone *) zone {
    
    return  [self.class shareInstance];
}

- (id) mutableCopyWithZone:(NSZone *) zone {
    
    return  [self.class shareInstance];
}


#pragma mark - http

- (void)AddUnionTermJump:(NSDictionary *)dict {
    
    [Inc_ODF_JumpFiber_HttpModel AddUnionTermJump:dict successBlock:^(id result) {
       
        if (result) {
            if (self.successBlock) {
                self.successBlock();
            }
            
        }
        
    }];
    
    
}



- (void)DeleteUnionTermJump:(NSDictionary *)dict {
    
    [Inc_ODF_JumpFiber_HttpModel DeleteUnionTermJump:dict successBlock:^(id result) {
       
        if (result) {
            if (self.successBlock) {
                self.successBlock();
            }
            
        }
        
    }];
    
    
}


//字符串转换
-(NSString *)eqpIdType:(NSString *)eqpIdType {
    
    NSString *eqpId_Type;
    
    switch (eqpIdType.intValue) {
        
        case 1: //odf
            eqpId_Type = @"302";
            break;
        
        case 2: //光交接
            eqpId_Type = @"703";
            break;
        
        case 3: //odb 分纤箱
            eqpId_Type = @"704";
            break;
            
        default:
            break;
    }
    return eqpId_Type;
}

@end
