//
//  Yuan_NewFL_VM.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL_VM.h"
#import "Yuan_NewFL_HttpModel.h"

@implementation Yuan_NewFL_VM

{
    // 与递归相关的参数
    NSMutableArray * _digui_SaveEptTypeIdArr;   // 存放递归内容的数据
}

#pragma mark - 声明单粒 ---

+ (Yuan_NewFL_VM *) shareInstance {
    
    static Yuan_NewFL_VM * instance = nil;
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


// 清空数据
- (void) clean_LinkChooseData {
    
    _LinkA_FiberChooseDict = nil;
    _LinkB_FiberChooseDict = nil;
    
    _LinkA_TerminalChooseDict = nil;
    _LinkB_TerminalChooseDict = nil;
    
    _LinkA_RouteChooseDict = nil;
    _LinkB_RouteChooseDict = nil;
}





//MARK:  保存端子事件的逻辑抽离

/// 保存端子点击事件 传参
/// @param selectDict 光路Id 查询光路内路由数据
/// @param myDict 设备数据
- (NSDictionary *) saveBusiness_Terminal:(NSDictionary *)selectDict
                              deviceDict:(NSDictionary *)myDict{
    
    
    NSString * device_resLogicName = myDict[@"resLogicName"];
    NSString * relateResId = myDict[@"GID"];
    NSString * relateResTypeId = @"";
    
    
    if ([device_resLogicName isEqualToString:@"ODF_Equt"]) {
        relateResTypeId = @"302";
    }
    
    else if ([device_resLogicName isEqualToString:@"OCC_Equt"]) {
        relateResTypeId = @"703";
    }
    else if ([device_resLogicName isEqualToString:@"ODB_Equt"]) {
        relateResTypeId = @"704";
    }
    else {
        relateResTypeId = @"";
    }
    
    
    
    // 光链路数组
    NSMutableArray * optPairLinkList = [NSMutableArray arrayWithArray:selectDict[@"optPairLinkList"]];
    
    // 单链路时
    if (optPairLinkList.count == 1 && self.numberOfLink == 1) {
        
        // 1链路数据
        NSMutableDictionary * optPairLinkDict = [NSMutableDictionary dictionaryWithDictionary:optPairLinkList.firstObject];
        
        NSMutableArray * optPairRouterList;
        
        // 如果已经存在了 optPairRouterList 证明已经有路由了 ,需要进行拼接
        if ([optPairLinkDict.allKeys containsObject:@"optPairRouterList"]) {
            
            // 链路内 , 路由的数据
            optPairRouterList = [NSMutableArray arrayWithArray:optPairLinkDict[@"optPairRouterList"]];
            
            NSDictionary * lastRouteDict = optPairRouterList.lastObject;
            NSString * lastSequence = [NSString stringWithFormat:@"%@",lastRouteDict[@"sequence"]];
            int nowSequence = lastSequence.intValue + 1;
            
            NSDictionary * newRouteDict = @{
                @"linkId" : optPairLinkDict[@"linkId"],
                @"sequence" : [Yuan_Foundation fromInt:nowSequence],
                @"eptTypeId" : @"317",  //端子一定是 317
                @"eptId" : _LinkA_TerminalChooseDict[@"GID"],
                @"eptName" : _LinkA_TerminalChooseDict[@"termName"],
                @"relateResId" : relateResId,
                @"relateResTypeId" : relateResTypeId
            };
            
            [optPairRouterList addObject:newRouteDict];
            
            
            optPairLinkDict[@"optPairRouterList"] = optPairRouterList;
            
            optPairLinkList[0] = optPairLinkDict;
            
        }
        // 如果不存在 , 那么我需要初始化
        else {
            
            // 链路内 , 路由的数据
            optPairRouterList = NSMutableArray.array;
            
            NSDictionary * newRouteDict = @{
                @"linkId" : optPairLinkDict[@"linkId"],
                @"sequence" : @"1",
                @"eptTypeId" : @"317",  //端子一定是 317
                @"eptId" : _LinkA_TerminalChooseDict[@"GID"],
                @"eptName" : _LinkA_TerminalChooseDict[@"termName"],
                @"relateResId" : relateResId,
                @"relateResTypeId" : relateResTypeId
            };
            
            [optPairRouterList addObject:newRouteDict];
            
            
            optPairLinkDict[@"optPairRouterList"] = optPairRouterList;
            
            optPairLinkList[0] = optPairLinkDict;
            
        }
        
        
    }
    
    // 双链路时
    if (optPairLinkList.count == 2 && self.numberOfLink == 2) {
        
        
        // 1链路数据
        NSMutableDictionary * optPairLinkDict_A = [NSMutableDictionary dictionaryWithDictionary:optPairLinkList.firstObject];
        
        NSMutableArray * optPairRouterList_A;
        
        // 如果已经存在了 optPairRouterList 证明已经有路由了 ,需要进行拼接
        if ([optPairLinkDict_A.allKeys containsObject:@"optPairRouterList"]) {
            
            // 链路内 , 路由的数据
            optPairRouterList_A = [NSMutableArray arrayWithArray:optPairLinkDict_A[@"optPairRouterList"]];
            
            NSDictionary * lastRouteDict = optPairRouterList_A.lastObject;
            NSString * lastSequence = [NSString stringWithFormat:@"%@",lastRouteDict[@"sequence"]];
            int nowSequence = lastSequence.intValue + 1;
            
            NSDictionary * newRouteDict = @{
                @"linkId" : optPairLinkDict_A[@"linkId"],
                @"sequence" : [Yuan_Foundation fromInt:nowSequence],
                @"eptTypeId" : @"317",  //端子一定是 317
                @"eptId" : _LinkA_TerminalChooseDict[@"GID"],
                @"eptName" : _LinkA_TerminalChooseDict[@"termName"],
                @"relateResId" : relateResId,
                @"relateResTypeId" : relateResTypeId
            };
            
            [optPairRouterList_A addObject:newRouteDict];
            
            
            optPairLinkDict_A[@"optPairRouterList"] = optPairRouterList_A;
            
            optPairLinkList[0] = optPairLinkDict_A;
            
        }
        // 如果不存在 , 那么我需要初始化
        else {
            
            // 链路内 , 路由的数据
            optPairRouterList_A = NSMutableArray.array;
            
            NSDictionary * newRouteDict = @{
                @"linkId" : optPairLinkDict_A[@"linkId"],
                @"sequence" : @"1",
                @"eptTypeId" : @"317",  //端子一定是 317
                @"eptId" : _LinkA_TerminalChooseDict[@"GID"],
                @"eptName" : _LinkA_TerminalChooseDict[@"termName"],
                @"relateResId" : relateResId,
                @"relateResTypeId" : relateResTypeId
            };
            
            [optPairRouterList_A addObject:newRouteDict];
            
            optPairLinkDict_A[@"optPairRouterList"] = optPairRouterList_A;
            
            optPairLinkList[0] = optPairLinkDict_A;
        }
        
        
    
        /// **** 第二条链路的数据 **** ****
        
        NSMutableDictionary * optPairLinkDict_B = [NSMutableDictionary dictionaryWithDictionary:optPairLinkList.lastObject];
        
        NSMutableArray * optPairRouterList_B;
        
        // 如果已经存在了 optPairRouterList 证明已经有路由了 ,需要进行拼接
        if ([optPairLinkDict_B.allKeys containsObject:@"optPairRouterList"]) {
            
            // 链路内 , 路由的数据
            optPairRouterList_B = [NSMutableArray arrayWithArray:optPairLinkDict_B[@"optPairRouterList"]];
            
            NSDictionary * lastRouteDict = optPairRouterList_B.lastObject;
            NSString * lastSequence = [NSString stringWithFormat:@"%@",lastRouteDict[@"sequence"]];
            int nowSequence = lastSequence.intValue + 1;
            
            NSDictionary * newRouteDict = @{
                @"linkId" : optPairLinkDict_B[@"linkId"],
                @"sequence" : [Yuan_Foundation fromInt:nowSequence],
                @"eptTypeId" : @"317",  //端子一定是 317
                @"eptId" : _LinkB_TerminalChooseDict[@"GID"],
                @"eptName" : _LinkB_TerminalChooseDict[@"termName"],
                @"relateResId" : relateResId,
                @"relateResTypeId" : relateResTypeId
            };
            
            [optPairRouterList_B addObject:newRouteDict];
            
            
            optPairLinkDict_B[@"optPairRouterList"] = optPairRouterList_B;
            
            optPairLinkList[1] = optPairLinkDict_B;
            
        }
        // 如果不存在 , 那么我需要初始化
        else {
            
            // 链路内 , 路由的数据
            optPairRouterList_B = NSMutableArray.array;
            
            NSDictionary * newRouteDict = @{
                @"linkId" : optPairLinkDict_B[@"linkId"],
                @"sequence" : @"1",
                @"eptTypeId" : @"317",  //端子一定是 317
                @"eptId" : _LinkB_TerminalChooseDict[@"GID"],
                @"eptName" : _LinkB_TerminalChooseDict[@"termName"],
                @"relateResId" : relateResId,
                @"relateResTypeId" : relateResTypeId
            };
            
            [optPairRouterList_B addObject:newRouteDict];
            
            
            optPairLinkDict_B[@"optPairRouterList"] = optPairRouterList_B;
            
            optPairLinkList[1] = optPairLinkDict_B;
            
        }
        
    }
    
    
    
    
    
    NSMutableDictionary * returnDict = [NSMutableDictionary dictionaryWithDictionary:selectDict];
    returnDict[@"optPairLinkList"] = optPairLinkList;
    
    
    return returnDict;
    
}




/// 保存端子点击事件 传参 --- 当双链路 并且长度不一致时的保存方式
/// @param selectDict 光路Id 查询光路内路由数据
/// @param myDict 设备数据
- (NSDictionary *) Links2_DoubleLinks_NotBothLength_SaveBusiness_Terminal:(NSDictionary *)selectDict
                                                               deviceDict:(NSDictionary *)myDict {
    
    NSString * device_resLogicName = myDict[@"resLogicName"];
    NSString * relateResId = myDict[@"GID"];
    NSString * relateResTypeId = @"";
    
    
    if ([device_resLogicName isEqualToString:@"ODF_Equt"]) {
        relateResTypeId = @"302";
    }
    
    else if ([device_resLogicName isEqualToString:@"OCC_Equt"]) {
        relateResTypeId = @"703";
    }
    else if ([device_resLogicName isEqualToString:@"ODB_Equt"]) {
        relateResTypeId = @"704";
    }
    else {
        relateResTypeId = @"";
    }
    
    
    // 光链路数组
    NSMutableArray * optPairLinkList = [NSMutableArray arrayWithArray:selectDict[@"optPairLinkList"]];
    
    NSDictionary * initDict ;
    NSDictionary * TerminalChooseDict;
    
    if (self.now_LinkNum == 1) {
        initDict = optPairLinkList.firstObject;
        TerminalChooseDict = _LinkA_TerminalChooseDict;
    }
    else {
        initDict = optPairLinkList.lastObject;
        TerminalChooseDict = _LinkB_TerminalChooseDict;
    }
    
    // 获取到对应的链路数据
    NSMutableDictionary * optPairLinkDict = [NSMutableDictionary dictionaryWithDictionary:initDict];
    
    NSMutableArray * optPairRouterList;
    
    // 如果已经存在了 optPairRouterList 证明已经有路由了 ,需要进行拼接
    if ([optPairLinkDict.allKeys containsObject:@"optPairRouterList"]) {
        
        // 链路内 , 路由的数据
        optPairRouterList = [NSMutableArray arrayWithArray:optPairLinkDict[@"optPairRouterList"]];
        
        NSDictionary * lastRouteDict = optPairRouterList.lastObject;
        NSString * lastSequence = [NSString stringWithFormat:@"%@",lastRouteDict[@"sequence"]];
        int nowSequence = lastSequence.intValue + 1;
        
        NSDictionary * newRouteDict = @{
            @"linkId" : optPairLinkDict[@"linkId"],
            @"sequence" : [Yuan_Foundation fromInt:nowSequence],
            @"eptTypeId" : @"317",  //端子一定是 317
            @"eptId" : TerminalChooseDict[@"GID"],
            @"eptName" : TerminalChooseDict[@"termName"],
            @"relateResId" : relateResId,
            @"relateResTypeId" : relateResTypeId
        };
        
        [optPairRouterList addObject:newRouteDict];
        
        
        optPairLinkDict[@"optPairRouterList"] = optPairRouterList;
        
        // 把数据还回去
        if (_now_LinkNum == 1) {
            optPairLinkList[0] = optPairLinkDict;
        }
        else {
            optPairLinkList[1] = optPairLinkDict;
        }
        
    }
    
    // 如果不存在 , 那么我需要初始化
    else {
        
        // 链路内 , 路由的数据
        optPairRouterList = NSMutableArray.array;
        
        NSDictionary * newRouteDict = @{
            @"linkId" : optPairLinkDict[@"linkId"],
            @"sequence" : @"1",
            @"eptTypeId" : @"317",  //端子一定是 317
            @"eptId" : TerminalChooseDict[@"GID"],
            @"eptName" : TerminalChooseDict[@"termName"],
            @"relateResId" : relateResId,
            @"relateResTypeId" : relateResTypeId
        };
        
        [optPairRouterList addObject:newRouteDict];
        
        
        optPairLinkDict[@"optPairRouterList"] = optPairRouterList;
        
        // 把数据还回去
        if (_now_LinkNum == 1) {
            optPairLinkList[0] = optPairLinkDict;
        }
        else {
            optPairLinkList[1] = optPairLinkDict;
        }
        
    }
    
    NSMutableDictionary * returnDict = [NSMutableDictionary dictionaryWithDictionary:selectDict];
    returnDict[@"optPairLinkList"] = optPairLinkList;
    
    return returnDict;
}





#pragma mark - 保存纤芯的事件抽离 ---


/// 保存纤芯时的 传参整理
/// @param selectDict 光路数据 -- 根据光路Id 查询光路下属路由的数据
/// @param myDict 我的光缆段map
/// @param isNeedRongJie 是否需要熔接
- (NSDictionary *) saveBusiness_Fiber:(NSDictionary *)selectDict
                           deviceDict:(NSDictionary *)myDict
                        isNeedRongJie:(BOOL)isNeedRongJie{
    
    
    NSString * relateResId = myDict[@"GID"];
    NSString * relateResTypeId = @"701";
    
    
    
    // 光链路数组
    NSMutableArray * optPairLinkList = [NSMutableArray arrayWithArray:selectDict[@"optPairLinkList"]];
    
    // 单链路时
    if (optPairLinkList.count == 1 && self.numberOfLink == 1) {
        
        // 1链路数据
        NSMutableDictionary * optPairLinkDict = [NSMutableDictionary dictionaryWithDictionary:optPairLinkList.firstObject];
        
        NSMutableArray * optPairRouterList;
        
        // 如果已经存在了 optPairRouterList 证明已经有路由了 ,需要进行拼接
        if ([optPairLinkDict.allKeys containsObject:@"optPairRouterList"]) {
            
            // 链路内 , 路由的数据
            optPairRouterList = [NSMutableArray arrayWithArray:optPairLinkDict[@"optPairRouterList"]];
            
            NSDictionary * lastRouteDict = optPairRouterList.lastObject;
            NSString * lastSequence = [NSString stringWithFormat:@"%@",lastRouteDict[@"sequence"]];
            int nowSequence = lastSequence.intValue + 1;
            
            NSDictionary * newRouteDict = @{
                @"linkId" : optPairLinkDict[@"linkId"] ?: @"",
                @"sequence" : [Yuan_Foundation fromInt:nowSequence],
                @"eptTypeId" : @"702",
                @"eptId" : _LinkA_FiberChooseDict[@"pairId"] ?: @"",
                @"eptName" : _LinkA_FiberChooseDict[@"pairNo"] ?: @"",
                @"relateResId" : relateResId,
                @"relateResTypeId" : relateResTypeId
            };
            
            // 需要传入  optTieInId 传输二机房
            if (isNeedRongJie) {
                
                NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:newRouteDict];
                mt_Dict[@"optTieInId"] = _nowSelectCableDevice_Dict[@"cableStart_Id"];
                [optPairRouterList addObject:mt_Dict];
            }else {
                
                [optPairRouterList addObject:newRouteDict];
            }
            
            
            optPairLinkDict[@"optPairRouterList"] = optPairRouterList;
            
            if (isNeedRongJie) {
                optPairLinkDict[@"optTieInId"] = _nowSelectCableDevice_Dict[@"cableStart_Id"];
            }
            
            optPairLinkList[0] = optPairLinkDict;
            
        }
        // 如果不存在 , 那么我需要初始化
        else {
            
            // 链路内 , 路由的数据
            optPairRouterList = NSMutableArray.array;
            
            NSDictionary * newRouteDict = @{
                @"linkId" : optPairLinkDict[@"linkId"],
                @"sequence" : @"1",
                @"eptTypeId" : @"702",
                @"eptId" : _LinkA_FiberChooseDict[@"pairId"] ?: @"",
                @"eptName" : _LinkA_FiberChooseDict[@"pairNo"] ?: @"",
                @"relateResId" : relateResId,
                @"relateResTypeId" : relateResTypeId
            };
            
            // 需要传入  optTieInId
            if (isNeedRongJie) {
                
                NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:newRouteDict];
                mt_Dict[@"optTieInId"] = _nowSelectCableDevice_Dict[@"cableStart_Id"];
                [optPairRouterList addObject:mt_Dict];
            }else {
                
                [optPairRouterList addObject:newRouteDict];
            }
            
            
            optPairLinkDict[@"optPairRouterList"] = optPairRouterList;
            
            if (isNeedRongJie) {
                optPairLinkDict[@"optTieInId"] = _nowSelectCableDevice_Dict[@"cableStart_Id"];
            }
            
            optPairLinkList[0] = optPairLinkDict;
            
        }
        
        
    }
    
    // 双链路时
    if (optPairLinkList.count == 2 && self.numberOfLink == 2) {
        
        
        // 1链路数据
        NSMutableDictionary * optPairLinkDict_A = [NSMutableDictionary dictionaryWithDictionary:optPairLinkList.firstObject];
        
        NSMutableArray * optPairRouterList_A;
        
        // 如果已经存在了 optPairRouterList 证明已经有路由了 ,需要进行拼接
        if ([optPairLinkDict_A.allKeys containsObject:@"optPairRouterList"]) {
            
            // 链路内 , 路由的数据
            optPairRouterList_A = [NSMutableArray arrayWithArray:optPairLinkDict_A[@"optPairRouterList"]];
            
            NSDictionary * lastRouteDict = optPairRouterList_A.lastObject;
            NSString * lastSequence = [NSString stringWithFormat:@"%@",lastRouteDict[@"sequence"]];
            int nowSequence = lastSequence.intValue + 1;
            
            NSDictionary * newRouteDict = @{
                @"linkId" : optPairLinkDict_A[@"linkId"],
                @"sequence" : [Yuan_Foundation fromInt:nowSequence],
                @"eptTypeId" : @"702",  //端子一定是 317
                @"eptId" : _LinkA_FiberChooseDict[@"pairId"],
                @"eptName" : _LinkA_FiberChooseDict[@"pairNo"],
                @"relateResId" : relateResId,
                @"relateResTypeId" : relateResTypeId
            };
            
            // 需要传入  optTieInId
            if (isNeedRongJie) {
                
                NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:newRouteDict];
                mt_Dict[@"optTieInId"] = _nowSelectCableDevice_Dict[@"cableStart_Id"];
                [optPairRouterList_A addObject:mt_Dict];
            }else {
                
                [optPairRouterList_A addObject:newRouteDict];
            }
            
            
            optPairLinkDict_A[@"optPairRouterList"] = optPairRouterList_A;
            
            if (isNeedRongJie) {
                optPairLinkDict_A[@"optTieInId"] = _nowSelectCableDevice_Dict[@"cableStart_Id"];
            }
            
            optPairLinkList[0] = optPairLinkDict_A;
            
        }
        // 如果不存在 , 那么我需要初始化
        else {
            
            // 链路内 , 路由的数据
            optPairRouterList_A = NSMutableArray.array;
            
            NSDictionary * newRouteDict = @{
                @"linkId" : optPairLinkDict_A[@"linkId"],
                @"sequence" : @"1",
                @"eptTypeId" : @"702",
                @"eptId" : _LinkA_FiberChooseDict[@"pairId"],
                @"eptName" : _LinkA_FiberChooseDict[@"pairNo"],
                @"relateResId" : relateResId,
                @"relateResTypeId" : relateResTypeId
            };
            
            // 需要传入  optTieInId
            if (isNeedRongJie) {
                
                NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:newRouteDict];
                mt_Dict[@"optTieInId"] = _nowSelectCableDevice_Dict[@"cableStart_Id"];
                [optPairRouterList_A addObject:mt_Dict];
            }else {
                
                [optPairRouterList_A addObject:newRouteDict];
            }
            
            
            optPairLinkDict_A[@"optPairRouterList"] = optPairRouterList_A;
            
            if (isNeedRongJie) {
                optPairLinkDict_A[@"optTieInId"] = _nowSelectCableDevice_Dict[@"cableStart_Id"];
            }
            
            optPairLinkList[0] = optPairLinkDict_A;
        }
        
        
    
        /// **** 第二条链路的数据 **** ****
        
        NSMutableDictionary * optPairLinkDict_B = [NSMutableDictionary dictionaryWithDictionary:optPairLinkList.lastObject];
        
        NSMutableArray * optPairRouterList_B;
        
        // 如果已经存在了 optPairRouterList 证明已经有路由了 ,需要进行拼接
        if ([optPairLinkDict_B.allKeys containsObject:@"optPairRouterList"]) {
            
            // 链路内 , 路由的数据
            optPairRouterList_B = [NSMutableArray arrayWithArray:optPairLinkDict_B[@"optPairRouterList"]];
            
            NSDictionary * lastRouteDict = optPairRouterList_B.lastObject;
            NSString * lastSequence = [NSString stringWithFormat:@"%@",lastRouteDict[@"sequence"]];
            int nowSequence = lastSequence.intValue + 1;
            
            NSDictionary * newRouteDict = @{
                @"linkId" : optPairLinkDict_B[@"linkId"],
                @"sequence" : [Yuan_Foundation fromInt:nowSequence],
                @"eptTypeId" : @"702",  //端子一定是 317
                @"eptId" : _LinkB_FiberChooseDict[@"pairId"],
                @"eptName" : _LinkB_FiberChooseDict[@"pairNo"],
                @"relateResId" : relateResId,
                @"relateResTypeId" : relateResTypeId
            };
            
            // 需要传入  optTieInId
            if (isNeedRongJie) {
                
                NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:newRouteDict];
                mt_Dict[@"optTieInId"] = _nowSelectCableDevice_Dict[@"cableStart_Id"];
                [optPairRouterList_B addObject:mt_Dict];
            }else {
                
                [optPairRouterList_B addObject:newRouteDict];
            }
            
            
            optPairLinkDict_B[@"optPairRouterList"] = optPairRouterList_B;
            
            if (isNeedRongJie) {
                optPairLinkDict_B[@"optTieInId"] = _nowSelectCableDevice_Dict[@"cableStart_Id"];
            }
            
            
            optPairLinkList[1] = optPairLinkDict_B;
            
        }
        // 如果不存在 , 那么我需要初始化
        else {
            
            // 链路内 , 路由的数据
            optPairRouterList_B = NSMutableArray.array;
            
            NSDictionary * newRouteDict = @{
                @"linkId" : optPairLinkDict_B[@"linkId"],
                @"sequence" : @"1",
                @"eptTypeId" : @"702",  //端子一定是 317
                @"eptId" : _LinkB_TerminalChooseDict[@"pairId"],
                @"eptName" : _LinkB_TerminalChooseDict[@"pairNo"],
                @"relateResId" : relateResId,
                @"relateResTypeId" : relateResTypeId
            };
            
            // 需要传入  optTieInId
            if (isNeedRongJie) {
                
                NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:newRouteDict];
                mt_Dict[@"optTieInId"] = _nowSelectCableDevice_Dict[@"cableStart_Id"];
                [optPairRouterList_B addObject:mt_Dict];
            }else {
                
                [optPairRouterList_B addObject:newRouteDict];
            }
            
            
            optPairLinkDict_B[@"optPairRouterList"] = optPairRouterList_B;
            
            if (isNeedRongJie) {
                optPairLinkDict_B[@"optTieInId"] = _nowSelectCableDevice_Dict[@"cableStart_Id"];
            }
            
            optPairLinkList[1] = optPairLinkDict_B;
            
        }
        
    }
    
    
    NSMutableDictionary * returnDict = [NSMutableDictionary dictionaryWithDictionary:selectDict];
    returnDict[@"optPairLinkList"] = optPairLinkList;
    
    
    return returnDict;
}




/// 保存纤芯时的 传参整理 --- 当双链路 并且长度不一致时的保存方式
/// @param selectDict 光路数据 -- 根据光路Id 查询光路下属路由的数据
/// @param myDict 我的光缆段map
/// @param isNeedRongJie 是否需要熔接
- (NSDictionary *) Links2_DoubleLinks_NotBothLength_SaveBusiness_Fiber:(NSDictionary *)selectDict
                                                            deviceDict:(NSDictionary *)myDict
                                                         isNeedRongJie:(BOOL)isNeedRongJie {
    
    NSString * relateResId = myDict[@"GID"];
    NSString * relateResTypeId = @"701";
    
    
    
    // 光链路数组
    NSMutableArray * optPairLinkList = [NSMutableArray arrayWithArray:selectDict[@"optPairLinkList"]];
    
    NSDictionary * initDict ;
    NSDictionary * FiberChooseDict;
    
    if (self.now_LinkNum == 1) {
        initDict = optPairLinkList.firstObject;
        FiberChooseDict = _LinkA_FiberChooseDict;
    }
    else {
        initDict = optPairLinkList.lastObject;
        FiberChooseDict = _LinkB_FiberChooseDict;
    }
    
    // 1链路数据
    NSMutableDictionary * optPairLinkDict = [NSMutableDictionary dictionaryWithDictionary:initDict];
    
    NSMutableArray * optPairRouterList;
    
    // 如果已经存在了 optPairRouterList 证明已经有路由了 ,需要进行拼接
    if ([optPairLinkDict.allKeys containsObject:@"optPairRouterList"]) {
        
        // 链路内 , 路由的数据
        optPairRouterList = [NSMutableArray arrayWithArray:optPairLinkDict[@"optPairRouterList"]];
        
        NSDictionary * lastRouteDict = optPairRouterList.lastObject;
        NSString * lastSequence = [NSString stringWithFormat:@"%@",lastRouteDict[@"sequence"]];
        int nowSequence = lastSequence.intValue + 1;
        
        NSDictionary * newRouteDict = @{
            @"linkId" : optPairLinkDict[@"linkId"] ?: @"",
            @"sequence" : [Yuan_Foundation fromInt:nowSequence],
            @"eptTypeId" : @"702",
            @"eptId" : FiberChooseDict[@"pairId"] ?: @"",
            @"eptName" : FiberChooseDict[@"pairNo"] ?: @"",
            @"relateResId" : relateResId,
            @"relateResTypeId" : relateResTypeId
        };
        
        // 需要传入  optTieInId 传输二机房
        if (isNeedRongJie) {
            
            NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:newRouteDict];
            mt_Dict[@"optTieInId"] = _nowSelectCableDevice_Dict[@"cableStart_Id"];
            [optPairRouterList addObject:mt_Dict];
        }else {
            
            [optPairRouterList addObject:newRouteDict];
        }
        
        
        optPairLinkDict[@"optPairRouterList"] = optPairRouterList;
        
        if (isNeedRongJie) {
            optPairLinkDict[@"optTieInId"] = _nowSelectCableDevice_Dict[@"cableStart_Id"];
        }
        
        
        // 把数据还回去
        if (_now_LinkNum == 1) {
            optPairLinkList[0] = optPairLinkDict;
        }
        else {
            optPairLinkList[1] = optPairLinkDict;
        }
        
        
    }
    // 如果不存在 , 那么我需要初始化
    else {
        
        // 链路内 , 路由的数据
        optPairRouterList = NSMutableArray.array;
        
        NSDictionary * newRouteDict = @{
            @"linkId" : optPairLinkDict[@"linkId"],
            @"sequence" : @"1",
            @"eptTypeId" : @"702",
            @"eptId" : FiberChooseDict[@"pairId"] ?: @"",
            @"eptName" : FiberChooseDict[@"pairNo"] ?: @"",
            @"relateResId" : relateResId,
            @"relateResTypeId" : relateResTypeId
        };
        
        // 需要传入  optTieInId
        if (isNeedRongJie) {
            
            NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:newRouteDict];
            mt_Dict[@"optTieInId"] = _nowSelectCableDevice_Dict[@"cableStart_Id"];
            [optPairRouterList addObject:mt_Dict];
        }else {
            
            [optPairRouterList addObject:newRouteDict];
        }
        
        
        optPairLinkDict[@"optPairRouterList"] = optPairRouterList;
        
        if (isNeedRongJie) {
            optPairLinkDict[@"optTieInId"] = _nowSelectCableDevice_Dict[@"cableStart_Id"];
        }
        
        // 把数据还回去
        if (_now_LinkNum == 1) {
            optPairLinkList[0] = optPairLinkDict;
        }
        else {
            optPairLinkList[1] = optPairLinkDict;
        }
        
    }
    
    
    NSMutableDictionary * returnDict = [NSMutableDictionary dictionaryWithDictionary:selectDict];
    returnDict[@"optPairLinkList"] = optPairLinkList;
    
    
    return returnDict;
}









//MARK:  保存局向光纤事件的逻辑抽离
- (NSDictionary *) saveBusiness_Route:(NSDictionary *)selectDict{
    

    // 光链路数组
    NSMutableArray * optPairLinkList = [NSMutableArray arrayWithArray:selectDict[@"optPairLinkList"]];
    
    // 单链路时
    if (optPairLinkList.count == 1 && self.numberOfLink == 1) {
        
        // 1链路数据
        NSMutableDictionary * optPairLinkDict = [NSMutableDictionary dictionaryWithDictionary:optPairLinkList.firstObject];
        
        NSMutableArray * optPairRouterList;
        
        // 如果已经存在了 optPairRouterList 证明已经有路由了 ,需要进行拼接
        if ([optPairLinkDict.allKeys containsObject:@"optPairRouterList"]) {
            
            // 链路内 , 路由的数据
            optPairRouterList = [NSMutableArray arrayWithArray:optPairLinkDict[@"optPairRouterList"]];
            
            NSDictionary * lastRouteDict = optPairRouterList.lastObject;
            NSString * lastSequence = [NSString stringWithFormat:@"%@",lastRouteDict[@"sequence"]];
            int nowSequence = lastSequence.intValue + 1;
            
            NSDictionary * newRouteDict = @{
                @"linkId" : optPairLinkDict[@"linkId"],
                @"sequence" : [Yuan_Foundation fromInt:nowSequence],
                @"eptTypeId" : @"731",  //局向是 731
                @"eptId" : _LinkA_RouteChooseDict[@"pairId"],
                @"eptName" : _LinkA_RouteChooseDict[@"pairNoDesc"],
                @"relateResId" : _LinkA_RouteChooseDict[@"pairId"],
                @"relateResTypeId" : @"713"
            };
            
            [optPairRouterList addObject:newRouteDict];
            
            optPairLinkDict[@"optPairRouterList"] = optPairRouterList;
            
            optPairLinkList[0] = optPairLinkDict;
            
        }
        // 如果不存在 , 那么我需要初始化
        else {
            
            // 链路内 , 路由的数据
            optPairRouterList = NSMutableArray.array;
            
            NSDictionary * newRouteDict = @{
                @"linkId" : optPairLinkDict[@"linkId"],
                @"sequence" : @"1",
                @"eptTypeId" : @"731",  //局向是 731
                @"eptId" : _LinkA_RouteChooseDict[@"pairId"],
                @"eptName" : _LinkA_RouteChooseDict[@"pairNoDesc"],
                @"relateResId" : _LinkA_RouteChooseDict[@"pairId"],
                @"relateResTypeId" : @"713"
            };
            
            [optPairRouterList addObject:newRouteDict];
            
            
            optPairLinkDict[@"optPairRouterList"] = optPairRouterList;
            
            optPairLinkList[0] = optPairLinkDict;
            
        }
        
    }
    
    // 双链路时
    if (optPairLinkList.count == 2 && self.numberOfLink == 2) {
        
        // 1链路数据
        NSMutableDictionary * optPairLinkDict_A = [NSMutableDictionary dictionaryWithDictionary:optPairLinkList.firstObject];
        
        NSMutableArray * optPairRouterList_A;
        
        // 如果已经存在了 optPairRouterList 证明已经有路由了 ,需要进行拼接
        if ([optPairLinkDict_A.allKeys containsObject:@"optPairRouterList"]) {
            
            // 链路内 , 路由的数据
            optPairRouterList_A = [NSMutableArray arrayWithArray:optPairLinkDict_A[@"optPairRouterList"]];
            
            NSDictionary * lastRouteDict = optPairRouterList_A.lastObject;
            NSString * lastSequence = [NSString stringWithFormat:@"%@",lastRouteDict[@"sequence"]];
            int nowSequence = lastSequence.intValue + 1;
            
            NSDictionary * newRouteDict = @{
                @"linkId" : optPairLinkDict_A[@"linkId"],
                @"sequence" : [Yuan_Foundation fromInt:nowSequence],
                @"eptTypeId" : @"731",  //局向是 731
                @"eptId" : _LinkA_RouteChooseDict[@"pairId"],
                @"eptName" : _LinkA_RouteChooseDict[@"pairNoDesc"],
                @"relateResId" : _LinkA_RouteChooseDict[@"pairId"],
                @"relateResTypeId" : @"713"
            };
            
            [optPairRouterList_A addObject:newRouteDict];
            
            optPairLinkDict_A[@"optPairRouterList"] = optPairRouterList_A;
            
            optPairLinkList[0] = optPairLinkDict_A;
            
        }
        // 如果不存在 , 那么我需要初始化
        else {
            // pairNoDesc
            // 链路内 , 路由的数据
            optPairRouterList_A = NSMutableArray.array;
            
            NSDictionary * newRouteDict = @{
                @"linkId" : optPairLinkDict_A[@"linkId"],
                @"sequence" : @"1",
                @"eptTypeId" : @"731",  //局向是 731
                @"eptId" : _LinkA_RouteChooseDict[@"pairId"],
                @"eptName" : _LinkA_RouteChooseDict[@"pairNoDesc"],
                @"relateResId" : _LinkA_RouteChooseDict[@"pairId"],
                @"relateResTypeId" : @"713"
            };
            
            [optPairRouterList_A addObject:newRouteDict];
            
            optPairLinkDict_A[@"optPairRouterList"] = optPairRouterList_A;
            
            optPairLinkList[0] = optPairLinkDict_A;
        }
        
        
    
        /// **** 第二条链路的数据 **** ****
        
        NSMutableDictionary * optPairLinkDict_B = [NSMutableDictionary dictionaryWithDictionary:optPairLinkList.lastObject];
        
        NSMutableArray * optPairRouterList_B;
        
        // 如果已经存在了 optPairRouterList 证明已经有路由了 ,需要进行拼接
        if ([optPairLinkDict_B.allKeys containsObject:@"optPairRouterList"]) {
            
            // 链路内 , 路由的数据
            optPairRouterList_B = [NSMutableArray arrayWithArray:optPairLinkDict_B[@"optPairRouterList"]];
            
            NSDictionary * lastRouteDict = optPairRouterList_B.lastObject;
            NSString * lastSequence = [NSString stringWithFormat:@"%@",lastRouteDict[@"sequence"]];
            int nowSequence = lastSequence.intValue + 1;
            
            NSDictionary * newRouteDict = @{
                @"linkId" : optPairLinkDict_B[@"linkId"],
                @"sequence" : [Yuan_Foundation fromInt:nowSequence],
                @"eptTypeId" : @"731",  //局向是 731
                @"eptId" : _LinkB_RouteChooseDict[@"pairId"],
                @"eptName" : _LinkB_RouteChooseDict[@"pairNoDesc"],
                @"relateResId" : _LinkB_RouteChooseDict[@"pairId"],
                @"relateResTypeId" : @"713"
            };
            
            [optPairRouterList_B addObject:newRouteDict];
            
            
            optPairLinkDict_B[@"optPairRouterList"] = optPairRouterList_B;
            
            optPairLinkList[1] = optPairLinkDict_B;
            
        }
        // 如果不存在 , 那么我需要初始化
        else {
            
            // 链路内 , 路由的数据
            optPairRouterList_B = NSMutableArray.array;
            
            NSDictionary * newRouteDict = @{
                @"linkId" : optPairLinkDict_B[@"linkId"],
                @"sequence" : [Yuan_Foundation fromInt:1],
                @"eptTypeId" : @"731",  //局向是 731
                @"eptId" : _LinkB_RouteChooseDict[@"pairId"],
                @"eptName" : _LinkB_RouteChooseDict[@"pairNoDesc"],
                @"relateResId" : _LinkB_RouteChooseDict[@"pairId"],
                @"relateResTypeId" : @"713"
            };
            
            [optPairRouterList_B addObject:newRouteDict];
            
            
            optPairLinkDict_B[@"optPairRouterList"] = optPairRouterList_B;
            
            optPairLinkList[1] = optPairLinkDict_B;
            
        }
        
    }
    
    
    
    
    
    NSMutableDictionary * returnDict = [NSMutableDictionary dictionaryWithDictionary:selectDict];
    returnDict[@"optPairLinkList"] = optPairLinkList;
    
    
    return returnDict;
    
}




#pragma mark - 光缆段去重 ---

/// 对光缆段进行去重处理 , 去掉已经出现在路由中的光缆段
/// @param data 根据设备返回回来的光缆段完整列表
- (NSArray *) cableList_Repeat:(NSArray *)data
                       linkArr:(NSArray *)linkArr {
    
    
    
    NSMutableArray * _cableIdsArr = NSMutableArray.array;
    
    NSDictionary * firstLinkRouteDict = linkArr.firstObject;
    // 获取链路1的路由
    NSArray * fir_optPairRouterList = firstLinkRouteDict[@"optPairRouterList"];
    
    // eptId eptTypeId
    for (NSDictionary * optPairRouter in fir_optPairRouterList) {
        
        // 纤芯
        if ([optPairRouter[@"eptTypeId"] isEqualToString:@"702"]) {
            NSString * cableId = optPairRouter[@"relateResId"];
            [_cableIdsArr addObject:cableId];
        }
        
        if ([optPairRouter[@"eptTypeId"] isEqualToString:@"731"]) {
         
            NSArray * optLogicRouteList = optPairRouter[@"optLogicRouteList"];
            
            for (NSDictionary * subRouteDict in optLogicRouteList) {
                
                // 纤芯
                if ([subRouteDict[@"nodeTypeId"] isEqualToString:@"702"]) {
                    // 路由内部的光缆段
                    [_cableIdsArr addObject:subRouteDict[@"rootId"]];
                }
                
            }
            
        }
        
    }
    
    // 如果有双芯 , 那么 2芯的数据也加入去重队伍中
    if (linkArr.count == 2 && self.numberOfLink == 2) {
        
        NSDictionary * secondLinkRouteDict = linkArr.lastObject;
        NSArray * sec_optPairRouterList = secondLinkRouteDict[@"optPairRouterList"];
        
        // eptId eptTypeId
        for (NSDictionary * optPairRouter in sec_optPairRouterList) {
            
            // 纤芯
            if ([optPairRouter[@"eptTypeId"] isEqualToString:@"702"]) {
                NSString * cableId = optPairRouter[@"relateResId"];
                [_cableIdsArr addObject:cableId];
            }
            
            if ([optPairRouter[@"eptTypeId"] isEqualToString:@"731"]) {
             
                NSArray * optLogicRouteList = optPairRouter[@"optLogicRouteList"];
                
                for (NSDictionary * subRouteDict in optLogicRouteList) {
                    
                    // 纤芯
                    if ([subRouteDict[@"nodeTypeId"] isEqualToString:@"702"]) {
                        // 路由内部的光缆段
                        [_cableIdsArr addObject:subRouteDict[@"rootId"]];
                    }
                    
                }
                
            }
        }
    }
    
    
    NSMutableArray * repeat_CableArr = NSMutableArray.array;
    
    for (NSDictionary * cableGetDict in data) {
        
        // 已经关联的光缆段Id 不涉及 新请求回来的所属光缆段列表中 , 则加入进去 , 可以展示
        if (![_cableIdsArr containsObject:cableGetDict[@"GID"]]) {
            [repeat_CableArr addObject:cableGetDict];
        }
        
    }
    
    
    return repeat_CableArr;
    
}



/// 对光缆段进行去重处理 , 去掉已经出现在路由中的光缆段 -- 二期
/// @param data 根据设备返回回来的光缆段完整列表
- (NSArray *) Links2_CableList_Repeat:(NSArray *)data
                              linkArr:(NSArray *)linkArr {
    
    
    
    NSMutableArray * _cableIdsArr = NSMutableArray.array;
    

    
    // eptId eptTypeId
    for (NSDictionary * optPairRouter in linkArr) {
        
        // 纤芯
        if ([optPairRouter[@"eptTypeId"] isEqualToString:@"702"]) {
            NSString * cableId = optPairRouter[@"relateResId"];
            [_cableIdsArr addObject:cableId];
        }
        
        if ([optPairRouter[@"eptTypeId"] isEqualToString:@"731"]) {
         
            NSArray * optLogicRouteList = optPairRouter[@"optLogicRouteList"];
            
            for (NSDictionary * subRouteDict in optLogicRouteList) {
                
                // 纤芯
                if ([subRouteDict[@"nodeTypeId"] isEqualToString:@"702"]) {
                    // 路由内部的光缆段
                    [_cableIdsArr addObject:subRouteDict[@"rootId"]];
                }
            }
        }
    }
    
    
    NSMutableArray * repeat_CableArr = NSMutableArray.array;
    
    for (NSDictionary * cableGetDict in data) {
        
        // 已经关联的光缆段Id 不涉及 新请求回来的所属光缆段列表中 , 则加入进去 , 可以展示
        if (![_cableIdsArr containsObject:cableGetDict[@"GID"]]) {
            [repeat_CableArr addObject:cableGetDict];
        }
        
    }
    
    
    return repeat_CableArr;
    
}




/// 对光缆段进行去重处理 , 去掉已经出现在路由中的光缆段
/// @param data 根据设备返回回来的光缆段完整列表
- (NSArray *) DoubleLinks_NotBothLength_CableList_Repeat:(NSArray *)data
                                                 linkArr:(NSArray *)linkArr {
    
    NSMutableArray * _cableIdsArr = NSMutableArray.array;
    
    NSDictionary * LinkRouteDict;
    
    if (_now_LinkNum == 1) {
        LinkRouteDict = linkArr.firstObject;
    }
    else {
        LinkRouteDict = linkArr.lastObject;
    }
    
    // 获取链路1的路由
    NSArray * optPairRouterList = LinkRouteDict[@"optPairRouterList"];
    
    // eptId eptTypeId
    for (NSDictionary * optPairRouter in optPairRouterList) {
        
        // 纤芯
        if ([optPairRouter[@"eptTypeId"] isEqualToString:@"702"]) {
            NSString * cableId = optPairRouter[@"relateResId"];
            [_cableIdsArr addObject:cableId];
        }
        
        if ([optPairRouter[@"eptTypeId"] isEqualToString:@"731"]) {
         
            NSArray * optLogicRouteList = optPairRouter[@"optLogicRouteList"];
            
            for (NSDictionary * subRouteDict in optLogicRouteList) {
                
                // 纤芯
                if ([subRouteDict[@"nodeTypeId"] isEqualToString:@"702"]) {
                    // 路由内部的光缆段
                    [_cableIdsArr addObject:subRouteDict[@"rootId"]];
                }
                
            }
            
        }
        
    }
    
    
    NSMutableArray * repeat_CableArr = NSMutableArray.array;
    
    for (NSDictionary * cableGetDict in data) {
        
        // 已经关联的光缆段Id 不涉及 新请求回来的所属光缆段列表中 , 则加入进去 , 可以展示
        if (![_cableIdsArr containsObject:cableGetDict[@"GID"]]) {
            [repeat_CableArr addObject:cableGetDict];
        }
        
    }
    
    
    return repeat_CableArr;
    
}


#pragma mark - 当前应该用哪个设备去请求光缆段 ---

- (void) nowSelectCableDevice:(NSArray *)firstLinkArr
                        block:(void(^)(NSDictionary * dict))block{
    
    /*
     relateResTypeId
     relateResId
     */
    
    if (!block) {
        return;
    }
    
    
    NSDictionary * lastRoute = firstLinkArr.lastObject;
    
    NSDictionary * dict = @{};
    
    //MARK: 1. 最后一个是 端子 , 那么 直接返回端子对应的设备Id 和 贝龙 cableStart_Type
    
    if ([lastRoute[@"eptTypeId"] isEqualToString:@"317"]) {
        dict = @{
            @"cableStart_Id" : lastRoute[@"relateResId"] ?: @"",
            @"cableStart_Type" : [self relateResTypeId_To_CableStart_Type:lastRoute[@"relateResTypeId"]]
        };
        _nowSelectCableDevice_Dict = dict;
        block(dict);
    }
    
    
    //MARK: 2. 最后一个是 纤芯 , 那么 根据纤芯 光缆段Id , 请去光缆段详细信息数据
    if ([lastRoute[@"eptTypeId"] isEqualToString:@"702"]) {
        
        NSString * cableId = lastRoute[@"relateResId"];
        
        if (!cableId) {
            return ;
        }
        
        // 倒数第二个 有可能是纤芯 也有可能是端子 , 要去判断他的情况
        NSDictionary * pt_Route = firstLinkArr[firstLinkArr.count - 2];
        NSString * pt_DeviceId = pt_Route[@"relateResId"];

        [Yuan_NewFL_HttpModel Http_GetCableDataFromCableId:cableId
                                                   success:^(id  _Nonnull lastResult) {

            
            NSArray * arr = lastResult;
            NSDictionary * last_CableDetail = arr.firstObject;
            
            // 如果倒数第二个是端子 , 那么取出端子对应的设备Id relateResId
            if ([pt_Route[@"eptTypeId"] isEqualToString:@"317"]) {
                
                
                
                NSString * last_Sid = last_CableDetail[@"sid"];
                NSString * last_Eid = last_CableDetail[@"eid"];
                
                NSDictionary * returnDict = @{};
                
                // 如果起始设备Id 与 倒数第二个设备Id 相同 , 那么拿终止Id 请求光缆段列表
                if ([last_Sid isEqualToString:pt_DeviceId]) {
                    returnDict = @{
                        @"cableStart_Id" : last_Eid,
                        @"cableStart_Type" : [self relateResTypeId_To_CableStart_Type:last_CableDetail[@"etypeId"]]
                    };
                    
                    _nowSelectCableDevice_Dict = returnDict;
                    block(returnDict);
                }
                
                // 如果终止设备Id 与 倒数第二个设备Id 相同 , 那么拿起始Id 请求光缆段列表
                else if ([last_Eid isEqualToString:pt_DeviceId]) {
                    
                    returnDict = @{
                        @"cableStart_Id" : last_Sid,
                        @"cableStart_Type" : [self relateResTypeId_To_CableStart_Type:last_CableDetail[@"stypeId"]]
                    };
                    _nowSelectCableDevice_Dict = returnDict;
                    block(returnDict);
                    
                }
                
                // 错误
                else {
                    _nowSelectCableDevice_Dict = returnDict;
                    block(returnDict);
                }
                
            }
            
            
            
            // 当倒数第二个是纤芯的时候  需要通过光缆段Id 请求光缆段数据 , 再一一进行对比
            if ([pt_Route[@"eptTypeId"] isEqualToString:@"702"]) {
                
                // 根据倒数第二个光缆段Id 请求光缆段详细信息数据
                [Yuan_NewFL_HttpModel Http_GetCableDataFromCableId:pt_DeviceId
                                                           success:^(id  _Nonnull result) {
                                    
                    NSArray * arr = result;
                    
                    if (arr.count == 0 || !arr) {
                        return;
                    }
                    
                    // 倒数第二个光缆段的详细信息数据
                    NSDictionary * pt_CableDict = arr.firstObject;
                    
                    // 最后一个光缆段 起始终止设备Id
                    NSString * last_Sid = last_CableDetail[@"sid"];
                    NSString * last_Eid = last_CableDetail[@"eid"];
                    
                    
                    // 倒数第二个光缆段 起始终止设备Id
                    NSString * pt_Sid = pt_CableDict[@"sid"];
                    NSString * pt_Eid = pt_CableDict[@"eid"];
                    
                    
                    NSDictionary * returnDict = @{};
                    NSString * deviceId = @"";
                    
                    // 证明 我需要的是 last_Eid
                    if ([last_Sid isEqualToString:pt_Sid] || [last_Sid isEqualToString:pt_Eid]) {
                        
                        deviceId = last_Eid;
                        
                        returnDict = @{
                            @"cableStart_Id" : deviceId,
                            @"cableStart_Type" : [self relateResTypeId_To_CableStart_Type:last_CableDetail[@"etypeId"]]
                        };
                        _nowSelectCableDevice_Dict = returnDict;
                        block(returnDict);
                        
                    }
                    
                    // 证明我需要的是 last_Sid
                    else if ([last_Eid isEqualToString:pt_Sid] || [last_Eid isEqualToString:pt_Eid]) {
                        deviceId = last_Sid;
                        
                        returnDict = @{
                            @"cableStart_Id" : deviceId,
                            @"cableStart_Type" : [self relateResTypeId_To_CableStart_Type:last_CableDetail[@"stypeId"]]
                        };
                        _nowSelectCableDevice_Dict = returnDict;
                        block(returnDict);
                        
                    }
                    
                    else {
                        _nowSelectCableDevice_Dict = returnDict;
                        block(returnDict);
                    }
                    
                }];
                
            }
        
        }];
    
    }
    
}




/// 大为的  relateResTypeId 转 贝龙的 cableStart_Type
- (NSString *) relateResTypeId_To_CableStart_Type:(NSString *)relateResTypeId {
    
        
    // 1 - ODF 302 ,  3 - 光交接箱 occ 703 , 4 - 光分纤箱和光终端盒 odb 704
    
    NSString * cableStart_Type = @"";
    
    
    switch (relateResTypeId.integerValue) {
        // odf
        case 302:
            cableStart_Type = @"1";
            break;
        
            // 接头
        case 705:
            cableStart_Type = @"2";
            break;
            
            // occ 光交接箱
        case 703:
            cableStart_Type = @"3";
            break;
            
        case 704:
            cableStart_Type = @"4";
            break;
            
        default:
            break;
    }
    
    
    
    return cableStart_Type;
}



/// 判断哪些能组成局向光纤
- (NSArray *) viewModel_ComboToRouters:(NSArray *) eptTypeIdArr {
    
    // 记录哪些端子已经拼接成了局向光纤
    NSMutableArray * isCombo_TerminalIndexArr = NSMutableArray.array;
    
    NSMutableArray * resultArr = NSMutableArray.array;
    
    NSInteger nowIndex = 0;
    for (NSString * eptTypeId in eptTypeIdArr) {
        
        // 如果不是端子 , 不在本次循环范围内
        if (![eptTypeId isEqualToString:@"317"]) {
            nowIndex++;
            continue;
        }
         
        // 该端子已经和某个端子组成局向光纤了 , 所以跳过
        if ([isCombo_TerminalIndexArr containsObject:@(nowIndex)]) {
            nowIndex++;
            continue;
        }
        
        
        _digui_SaveEptTypeIdArr = NSMutableArray.array;
        
        // 开始递归 -- 拿到递归终点的index  , 如果可以形成局向光纤的话 , 否则返回0
        [self digui_SelectRouters:eptTypeIdArr nowIndex:nowIndex];
        
        // 证明寻找可以组合成局向光纤的数据失败了
        if (_digui_SaveEptTypeIdArr.count == 0) {
            nowIndex++;
            continue;
        }
        
        // 找到了
        else {
            
            [resultArr addObject:@{
                @"start" : @(nowIndex),
                @"end" : @(nowIndex + _digui_SaveEptTypeIdArr.count - 1)
            }];
            
            [isCombo_TerminalIndexArr addObject:@(nowIndex)];
            [isCombo_TerminalIndexArr addObject:@(nowIndex + _digui_SaveEptTypeIdArr.count - 1)];
        }
        
        nowIndex++;
    }
    
    
    return resultArr;
}


- (void) digui_SelectRouters:(NSArray *)eptTypeIdArr
                         nowIndex:(NSInteger)nowIndex {
    
    NSInteger copyIndex = nowIndex;
    
    
    
    /// 何时终止递归 --- --- ---
    // 1. 当即将数组越界时 -- 失败
    if (copyIndex > eptTypeIdArr.count - 1) {
        
        // 清空
        [_digui_SaveEptTypeIdArr removeAllObjects];
        return ;
    }
    
    NSString * nowEptTypeId = eptTypeIdArr[nowIndex];
    
    // 如果当前循环到的不是端子或者纤芯 则失败
    if (![nowEptTypeId isEqualToString:@"317"] && ![nowEptTypeId isEqualToString:@"702"]) {
        
        // 清空
        [_digui_SaveEptTypeIdArr removeAllObjects];
        return ;
    }
    
    
    // 2. 当发现有可以组合成局向光纤的对端端子时 -- 成功
    if ([nowEptTypeId isEqualToString:@"317"] && _digui_SaveEptTypeIdArr.count >2) {
        [_digui_SaveEptTypeIdArr addObject:eptTypeIdArr[copyIndex]];
        return;
    }
    
    // 3. 继续递归 ---
    else {
        
     
        
        [_digui_SaveEptTypeIdArr addObject:eptTypeIdArr[copyIndex]];
        
        // 递归成功
        if ([eptTypeIdArr[copyIndex] isEqualToString:@"317"] && _digui_SaveEptTypeIdArr.count > 1) {
            return;
        }
        
        [self digui_SelectRouters:eptTypeIdArr nowIndex:copyIndex + 1];
    }
    
}



/// 根据 -- 端子纤芯端子 生成一个新的 , 无id的局向光纤 , 作为占位符
- (NSDictionary *) viewModel_GetNewRouterFromTerminalAndFibers:(NSArray *) subRoutes {
    
    NSMutableDictionary * newRouterDict = NSMutableDictionary.dictionary;
    
    
    newRouterDict[@"eptTypeId"] = @"731";
    newRouterDict[@"eptName"] = @"点击生成局向光纤后操作";
    newRouterDict[@"isOpen"] = @"1";
    newRouterDict[@"localCreate"] = @"1";
    
    NSMutableArray * routers = NSMutableArray.array;
    
    NSInteger index = 1;
    
    for (NSDictionary * singleRouteDict in subRoutes) {
        
        NSMutableDictionary * mt_D = [NSMutableDictionary dictionaryWithDictionary:singleRouteDict];
        
        mt_D[@"pairId"] = NSNull.null;
        mt_D[@"sequence"] = [Yuan_Foundation fromInteger:index];
        
        mt_D[@"nodeTypeId"] = singleRouteDict[@"eptTypeId"];
        mt_D[@"nodeName"] = singleRouteDict[@"eptName"];
        mt_D[@"nodeId"] = @"";
        
        mt_D[@"rootId"] = singleRouteDict[@"relateResId"];
        mt_D[@"rootTypeId"] = singleRouteDict[@"relateResTypeId"];
        mt_D[@"rootName"] = singleRouteDict[@"relateResName"] ?: @"无";
        
        mt_D[@"oldSequence"] = singleRouteDict[@"sequence"];
        
        [routers addObject:mt_D];
        index++;
    }
    
    
    
    newRouterDict[@"optLogicRouteList"] = routers;
    
    return newRouterDict;
}

- (void)setNumberOfLink:(int)numberOfLink {
    _numberOfLink = numberOfLink;
}



/// 倒叙当前的光链路节点数组
- (NSArray *) configNowLinkRouters_flashback {
    
    NSMutableArray *temp = [NSMutableArray arrayWithArray:_nowLinkRouters];
    temp = (NSMutableArray *)[[temp reverseObjectEnumerator] allObjects];
    
    return temp;
}

+ (BOOL) isNew_2021 {
    
    return false;
}


/// 是否是 光路纤芯衰耗分解
+ (BOOL) isFiberDecay {
    return false;
}

@end
