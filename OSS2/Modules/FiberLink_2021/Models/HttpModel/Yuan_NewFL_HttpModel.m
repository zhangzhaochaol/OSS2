//
//  Yuan_NewFL_HttpModel.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL_HttpModel.h"

#import "Yuan_WebService.h"
#import "Yuan_NewFL_VM.h"
#import "Inc_NewMB_HttpModel.h"

#pragma mark - 一期接口 ---
// 条件查询光链路列表
static NSString * NewFL_LinkListPort = @"optRes/findOptRoadByCondition";

// 条件查询局向光纤列表
static NSString * NewFL_RouteListPort = @"optRes/findOptLogicPairByCondition";

// 光路Id下属路由查询
static NSString * NewFL_LinkSubRouteSelectPort = @"optRes/findOptRoadRouteByRoadId";

// 根据局向光纤Id 查询局向光纤下属路由
static NSString * NewFL_RouteId_SelectSubRoute = @"optRes/findOptLogicPairByPairId";

// 对光链路路由中 新增节点
static NSString * NewFL_AddEptPort = @"lineApi/addOptPairRouter";

// 初始化光路内的光链路
static NSString * NewFL_CreateLinksPort = @"lineApi/initOptPairLinkByRoadId";

// 根据端子或纤芯Id 查询该端子所在的链路
static NSString * NewFL_SearchLinksFromRouteId = @"optRes/findOptPairRouterByEpt";


// 根据端子Id 查询所在光路路由数据
static NSString * NewFL_SearchLinkRouteFromTerminalId = @"optRes/findOptRoadRouteByTermId";

// *** 辅助接口

// 根据端子纤芯 查询上级设备
static NSString * NewFL_FromTerminalOrFiber_SelectSuperDevicePort = @"optRes/findSuperResBySubRes";

// 根据光缆段Id 查询光缆段详细信息数据
static NSString * NewFL_GetCableDataFromCableId = @"optRes/selectOptSectByCondition";


// 根据端子的Id 查询端子当前的成端状态
static NSString * NewFL_GetTerminalStateFromTerminalIds = @"optRes/findTermStateByTermIds";

// 根据光链路id 查询光链路的详细信息
static NSString * NewFL2_GetLinkDatasFromLinkId = @"optRes/selectOptPairLinkByLinkId";



#pragma mark - 二期接口 ---

// 根据端子纤芯等节点 , 创建局向光纤
static NSString * NewFL2_CreateRoute = @"lineApi/creatLogicOptPair";

// 光链路路由节点的替换
static NSString * NewFL2_ExchangeRouterFromLinks = @"lineApi/replaceOptLinkEpt";

// 局向光纤路由节点的替换
static NSString * NewFL2_ExchangeRouterFromRoute = @"lineApi/replaceLogicOptPairEpt";

// 光链路路由节点的删除
static NSString * NewFL2_DeleteRouterPointFromLinksFromLinks = @"lineApi/removeOptLink";

// 局向光纤路由节点的删除
static NSString * NewFL2_DeleteRouterFromRoute = @"lineApi/removeLogicOptPair";

// 通过端子或纤芯 , 查看是否有成端熔接 , 局向光纤 光链路关系 等
static NSString * NewFL2_SelectFriendShipPoint = @"optRes/selectRelationByTermId";



// 光链路插入接口
static NSString * NewFL2_LinksInsertPort = @"lineApi/insertOptLinkEpt";

// 局向光纤插入接口
static NSString * NewFL2_RoutesInsertPort = @"lineApi/insertLogicOptPairEpt";

// 局向光纤查询接口
static NSString * NewFL2_SelectRouteList = @"optRes/selectOptLogicOptPairByRootId";




#pragma mark - 三期接口 ---

// 根据局向光纤id 或 光链路id 查询节点设备的经纬度
static NSString * NewFL3_SelectPointCoor = @"optRes/findRoutePathByLinkId";

// 根据端子或纤芯 查询所在局向光纤
static NSString * NewFL3_SelectRouteFromTerFib = @"optRes/searchOptLogicPairAndRoutesByNodeId";




@implementation Yuan_NewFL_HttpModel


/// 条件查询光链路
+ (void) Http_SelectLinkList:(NSDictionary *)param
                     success:(void(^)(id result))success {
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:param];
    dict[@"pageSize"] = @"100";
    dict[@"pageNum"] = @"1";
    [Http.shareInstance DavidJsonPostURL:[self URL:NewFL_LinkListPort]
                                   Parma:dict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
    
}


/// 条件查询局向光纤
+ (void) Http_SelectRouteList:(NSDictionary *)param
                      success:(void(^)(id result))success {
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:param];
    dict[@"pageSize"] = @"100";
    dict[@"pageNum"] = @"1";
    
    [Http.shareInstance DavidJsonPostURL:[self URL:NewFL_RouteListPort]
                                   Parma:dict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
}


/// 根据局向光纤Id 查询下属路由
+ (void) Http_SelectRouteFromId:(NSString *)routeId
                        success:(void(^)(id result))success {
    
    
    NSDictionary * dict = @{
        @"id" : routeId
    };
    
    [Http.shareInstance DavidJsonPostURL:[self URL:NewFL_RouteId_SelectSubRoute]
                                   Parma:dict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
}


/// 根据光路Id 查询下属路由
+ (void) Http_SelectLinkFromId:(NSString *)linkId
                       success:(void(^)(id result))success {
    
    
    NSDictionary * dict = @{
        @"id" : linkId
    };
    
    [Http.shareInstance DavidJsonPostURL:[self URL:NewFL_LinkSubRouteSelectPort]
                                   Parma:dict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
}


/// 光链路中 新增路由节点
+ (void) Http_LinkAddEpt:(NSDictionary *) dict
                 success:(void(^)(id result))success {
    
    NSDictionary * newLinkRouteArr = @{
        @"optRoadAndLink" : dict
    };
    
    [Http.shareInstance DavidJsonPostURL:[self EditURL:NewFL_AddEptPort]
                                   Parma:newLinkRouteArr
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
}




/// 根据光路内链路个数 初始化光链路
+ (void) Http_CreateLinesFromLinkId:(NSString *)linkId
                            success:(void(^)(id result))success {
    
    NSDictionary * param = @{
        @"id" : linkId
    };
    
    
    [Http.shareInstance DavidJsonPostURL:[self EditURL:NewFL_CreateLinksPort]
                                   Parma:param
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
        
    }];
    
}



/// 根据路由节点的Id查询所在光链路
/// @param routeId 节点id
/// @param routeTypeId 节点类型id
+ (void) Http_SearchLinksFromRouterId:(NSString *)routeId
                          routeTypeId:(NSString *)routeTypeId
                              success:(void(^)(id result))success {
    
    
    NSDictionary * postDict = @{
        @"id" : routeId,
        @"type" : routeTypeId
    };
    
    
    [Http.shareInstance DavidJsonPostURL:[self URL:NewFL_SearchLinksFromRouteId]
                                   Parma:postDict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
        
    }];
    
}




/// 根据端子id 查询光路路由数据
+ (void) Http_SearchLinkRouteFromTerminalId:(NSString *) terminalId
                                    success:(void(^)(id result))success {
    
    NSDictionary * postDict = @{
        @"id" : terminalId
    };
    
    
    [Http.shareInstance DavidJsonPostURL:[self URL:NewFL_SearchLinkRouteFromTerminalId]
                                   Parma:postDict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
        
    }];
    
}


#pragma mark - 辅助接口 非业务相关的接口---


/// 根据光缆段Id 查询光缆段详细信息数据
+ (void) Http_GetCableDataFromCableId:(NSString *) cableId
                              success:(void(^)(id result))success {
    
    
    [Http.shareInstance DavidJsonPostURL:[self URL:NewFL_GetCableDataFromCableId]
                                   Parma:@{@"optSectId" : cableId}
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
        
    }];
    
    
}



/// 清空 辅助接口
+ (void) Http_ClearLinkId:(NSString *)Id_A
                      IdB:(NSString *)Id_B
                  success:(void(^)(id result))success {
    
    if (!Id_A) {
        [YuanHUD HUDFullText:@"缺少链路1的Id"];
        return;
    }
    
    
    NSArray * arr = @[
    
        @{
            @"gid" : Id_A,
            @"routes" : @[],
            @"beginTermId" : [NSNull null],
            @"endTermId" : [NSNull null]
        }
    ];
    
    
    NSMutableArray * mt_arr = [NSMutableArray arrayWithArray:arr];
    
    if (Id_B) {
        
        [mt_arr addObject:@{
            @"gid" : Id_B,
            @"routes" : @[],
            @"beginTermId" : [NSNull null],
            @"endTermId" : [NSNull null]
        }];
    }
    
    
    
    NSDictionary * dict = @{
        @"provinceCode" : @"heilongjiang",
        @"resType" : @"optPairLink" ,
        @"isProduction" : [NSNumber numberWithBool:true],
        @"datas" : mt_arr.json
    };
    
    
    [Http.shareInstance DavidJsonPostURL:[NSString stringWithFormat:@"%@unionEditApi/editRes",Http.David_DeleteUrl]
                                   Parma:dict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
}





/// 根据端子纤芯数据 反查父设备数据  --- 端子查设备 , 纤芯查光缆段
+ (void) Http_GetFiberOrTerminal_SuperDataFromArray:(NSArray *) array
                                            success:(void(^)(id result))success {
    
    
    
    [Http.shareInstance DavidJsonPostURL:[self URL:NewFL_FromTerminalOrFiber_SelectSuperDevicePort]
                                   Parma:@{@"resTypeList":array}
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
        
    }];
    
}


/// 根据端子的Id , 查询当前的端子状态 是否已成端
+ (void) Http_SelectTerminalsStateFromIds:(NSArray *)terminalIds
                                  success:(void(^)(id result))success {
    
    
    
    [Http.shareInstance DavidJsonPostURL:[self URL:NewFL_GetTerminalStateFromTerminalIds]
                                   Parma:@{@"resIds":terminalIds}
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
        
    }];
    
}


/// 验证端子或者纤芯 或者是局向光纤 是否已经有关系了
+ (void) Http2_CheckChooseTerminalOrFiberShip:(NSDictionary *) TF_Dict
                                      success:(void(^)(id result))success {
    
    [Http.shareInstance DavidJsonPostURL:David_SelectUrl(NewFL2_SelectFriendShipPoint)
                                   Parma:TF_Dict
                                 success:^(id result) {
        if (success) {
            success(result);
        }
    }];
    
}


+ (void) Http2_GetLinkFromLinkId:(NSString *) linkId
                         success:(void(^)(id result))success {
    
    
    [Http.shareInstance DavidJsonPostURL:David_SelectUrl(NewFL2_GetLinkDatasFromLinkId)
                                   Parma:@{@"id" : linkId}
                                 success:^(id result) {
        if (success) {
            success(result);
        }
    }];
    
}



+ (NSString *) URL:(NSString *) str {
    return  [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,str];
}


+ (NSString *) EditURL:(NSString *) str {
    
    return [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,str];
}



#pragma mark - 二期 2021.10 ---

/// 哪些组合成新的局向光纤?
+ (void) Http2_ComboRouteFromComboArr:(NSArray *) datas
                              success:(void(^)(id result))success {
    
    
    NSDictionary * postDict = @{@"optPairRouterList" : datas};
    
    [Http.shareInstance DavidJsonPostURL:David_ModifiUrl(NewFL2_CreateRoute)
                                   Parma:postDict success:^(id result) {
        if (success) {
            success(result);
        }
    }];
    
    
}



/// 光链路路由节点的替换
+ (void) Http2_ExchangeRouterPointInLinks:(NSDictionary *) exchangePostDict
                           success:(void(^)(id result))success {
    
    
    
    [Http.shareInstance DavidJsonPostURL:David_ModifiUrl(NewFL2_ExchangeRouterFromLinks)
                                   Parma:exchangePostDict success:^(id result) {
        if (success) {
            success(result);
        }
    }];
}


/// 局向光纤路由节点的替换
+ (void) Http2_ExchangeRouterPointInRoutes:(NSDictionary *) exchangePostDict
                                   success:(void(^)(id result))success {
 
    [Http.shareInstance DavidJsonPostURL:David_ModifiUrl(NewFL2_ExchangeRouterFromRoute)
                                   Parma:exchangePostDict
                                 success:^(id result) {
        if (success) {
            success(result);
        }
    }];
    
}



/// 光链路路由和局向光纤路由节点的删除
+ (void) Http2_DeleteRouterPoint:(NSDictionary *) deleteDict
                          isLink:(BOOL) isLink
                         success:(void(^)(id result))success{
    
    NSString * url = NewFL2_DeleteRouterFromRoute;
    
    if (isLink) {
        url = NewFL2_DeleteRouterPointFromLinksFromLinks;
    }
    
    
    [Http.shareInstance DavidJsonPostURL:David_ModifiUrl(url)
                                   Parma:@{@"swapTerm" : deleteDict}
                                 success:^(id result) {
        if (success) {
            success(result);
        }
    }];
}


/// 光链路路由节点的插入
+ (void) Http2_InsertInLinks:(NSDictionary *) insertDict
                 insertIndex:(NSInteger) insertIndex
                       links:(NSArray *) links
                     success:(void(^)(id result))success {
    

    
    NSMutableDictionary * newDict = NSMutableDictionary.dictionary;
    
    // 证明是纤芯
    if ([insertDict.allKeys containsObject:@"pairId"] &&
        ![insertDict.allKeys containsObject:@"eptTypeId"]) {
        
        newDict[@"eptId"] = insertDict[@"pairId"];
        newDict[@"eptName"] = insertDict[@"pairName"];
        newDict[@"eptTypeId"] = @"702";
        
        // relateRes root
        newDict[@"relateResId"] = insertDict[@"optSectId"];
        newDict[@"relateResName"] = insertDict[@"optSectName"];
        newDict[@"relateResTypeId"] = @"701";
        
        // 传入linkId
        newDict[@"linkId"] = insertDict[@"linkId"] ?: @"";
    }
    
    // 是端子
    if([insertDict.allKeys containsObject:@"termName"]) {
        
        newDict[@"eptId"] = insertDict[@"GID"];
        newDict[@"eptName"] = insertDict[@"termName"];
        newDict[@"eptTypeId"] = @"317";
        
        
        NSString * eqp_TypeId = insertDict[@"eqpId_Type"];
        NSString * eqpId_Type ;
        
        switch (eqp_TypeId.intValue) {
                
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
                eqpId_Type = @"";
                break;
        }

        // relateRes root
        newDict[@"relateResId"] = insertDict[@"eqpId_Id"];
        newDict[@"relateResName"] = insertDict[@"eqpId"];
        newDict[@"relateResTypeId"] = eqpId_Type;
        
        // 传入linkId
        newDict[@"linkId"] = insertDict[@"linkId"] ?: @"";
    }
    
    // 是局向光纤
    if ([insertDict.allKeys containsObject:@"pairId"] &&
        [insertDict[@"eptTypeId"] isEqualToString:@"731"]) {
     
        newDict[@"eptId"] = insertDict[@"pairId"];
        newDict[@"eptName"] = insertDict[@"pairNoDesc"];
        newDict[@"eptTypeId"] = @"731";
        
        // relateRes root
        newDict[@"relateResId"] = insertDict[@"pairId"];
        newDict[@"relateResName"] = insertDict[@"pairNoDesc"];
        newDict[@"relateResTypeId"] = @"731";
        
        // 传入linkId
        newDict[@"linkId"] = insertDict[@"linkId"] ?: @"";
    }
    
    
    NSMutableArray * copyLinks = [NSMutableArray arrayWithArray:links];
    
    if (insertIndex + 1 > copyLinks.count) {
        NSLog(@"数组越界");
        return;
    }
    
    Yuan_NewFL_VM * VM = Yuan_NewFL_VM.shareInstance;
    
    if (VM.insertMode == NewFL2_InsertMode_Up) {
        [copyLinks insertObject:newDict atIndex:0];
    }
    else {
        [copyLinks insertObject:newDict atIndex:insertIndex + 1];
    }
    
    
    // changeRouterList
    // optPairRouter
    
    NSDictionary * postDict = @{
        
        @"changeRouterList" : copyLinks,
        @"optPairRouter" : newDict,
    };
    
    [Http.shareInstance DavidJsonPostURL:David_ModifiUrl(NewFL2_LinksInsertPort)
                                   Parma:postDict
                                 success:^(id result) {
        if (success) {
            success(result);
        }
    }];
    
}



/// 局向光纤节点的插入
+ (void) Http2_InsertInRoutes:(NSDictionary *) insertDict
                  insertIndex:(NSInteger) insertIndex
                        links:(NSArray *) links
                      success:(void(^)(id result))success {
    

    
    
    NSMutableDictionary * newDict = NSMutableDictionary.dictionary;
    
    // 证明是纤芯
    if ([insertDict.allKeys containsObject:@"pairId"]) {
        
        newDict[@"nodeId"] = insertDict[@"pairId"];
        newDict[@"nodeName"] = insertDict[@"pairName"];
        newDict[@"nodeTypeId"] = @"702";
        
        // relateRes root
        newDict[@"rootName"] = insertDict[@"optSectName"];
        newDict[@"rootId"] = insertDict[@"optSectId"];
        newDict[@"rootTypeId"] = @"701";
    }
    
    // 是端子
    else {
        
        newDict[@"nodeId"] = insertDict[@"GID"];
        newDict[@"nodeName"] = insertDict[@"termName"];
        newDict[@"nodeTypeId"] = @"317";
        
        
        NSString * eqp_TypeId = insertDict[@"eqpId_Type"];
        NSString * eqpId_Type ;
        
        switch (eqp_TypeId.intValue) {
                
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
                eqpId_Type = @"";
                break;
        }

        // relateRes root
        newDict[@"rootId"] = insertDict[@"eqpId_Id"];
        newDict[@"rootName"] = insertDict[@"eqpId"];
        newDict[@"rootTypeId"] = eqpId_Type;
    }
    
    
    NSMutableArray * copyLinks = [NSMutableArray arrayWithArray:links];
    
    if (insertIndex + 1 > copyLinks.count) {
        NSLog(@"数组越界");
        return;
    }
    
    [copyLinks insertObject:newDict atIndex:insertIndex + 1];
    
    // optLogicRouteList
    // optLogicPairRoute
    
    NSDictionary * postDict = @{
        
        @"optLogicRouteList" : copyLinks,
        @"optLogicPairRoute" : newDict,
    };
    
    [Http.shareInstance DavidJsonPostURL:David_ModifiUrl(NewFL2_RoutesInsertPort)
                                   Parma:postDict
                                 success:^(id result) {
        if (success) {
            success(result);
        }
    }];
    
}


/// 根据设备id和类型 查询同设备的局向光纤
+ (void) Http2_SelectRoutesList:(NSDictionary *) dict
                        success:(void(^)(id result))success{

    /*
     双设备查询
     aeqpId
     aeqpType
     zeqpId
     zeqpType

     单设备查询
     eqpId
     eqpType
     */
    
    [Http.shareInstance DavidJsonPostURL:David_SelectUrl(NewFL2_SelectRouteList)
                                   Parma:dict
                                 success:^(id result) {
        if (success) {
            success(result);
        }
    }];
    
}

#pragma mark - 三期 2022.03 ---

/// 根据光链路 局向光纤id 查询对应父类的 经纬度信息 , 绘制在地图上
+ (void) Http3_SelectPointCoorsDict:(NSDictionary *) dict
                            success:(httpSuccessBlock)success {

    [Http.shareInstance DavidJsonPostURL:David_SelectUrl(NewFL3_SelectPointCoor)
                                   Parma:dict
                                 success:^(id result) {
        if (success) {
            success(result);
        }
    }];
}


/// 根据端子或者纤芯 , 查询所在的局向光纤
+ (void) Http3_SelectRouteFromTerFibDict:(NSDictionary *) dict
                                 success:(httpSuccessBlock)success {
    
    [Http.shareInstance DavidJsonPostURL:David_SelectUrl(NewFL3_SelectRouteFromTerFib)
                                   Parma:dict
                                 success:^(id result) {
        if (success) {
            success(result);
        }
    }];
    
}



/// 衰耗分解接口
+ (void) Http3_DecayPortDict:(NSDictionary *) dict
                     success:(httpSuccessBlock)success {

    
    NSArray * cableIds = dict[@"cableIds"];
    NSArray * fiberIds = dict[@"fiberIds"];
    
    float value = [dict[@"value"] floatValue];
    
    NSDictionary * selectDict = @{
        @"ids" : cableIds,
        @"type" : @"optSect"
    };
    
    NSString * Url = @"unionSearch/unionSearchById";
    
    
    [Inc_NewMB_HttpModel HTTP_NewMB_SelectDetailsFromIdWithURL:Url
                                                          Dict:selectDict
                                                       success:^(id  _Nonnull result) {
            
        NSArray * resArr = result;
        float sumLength = 0;
        
        for (NSDictionary * cable in resArr) {
            
            NSString * length = cable[@"length"];
            
            if (length) {
                sumLength += length.floatValue;
            }
        }
        
        
        if (resArr.count != cableIds.count ) {
            [YuanHUD HUDFullText:@"数据错误"];
            return;
        }
        
        NSMutableArray * mt_PostArr = NSMutableArray.array;
        
        NSInteger index = 0;
        
        for (NSDictionary * cable in resArr) {
                
            
            NSString * fiberId = fiberIds[index];
            NSString * length = cable[@"length"];
            
            if (length) {
                
                float DecayModules = value / sumLength * length.floatValue;
                
                NSDictionary * changeDict = @{
                    @"gid" : fiberId,
                    @"lightAttenuationCoefficient" : @(DecayModules)
                };
                
                [mt_PostArr addObject:changeDict];
            }
            
            index++;
        }
        
        
        NSDictionary * modifiPostDict = @{
          
            @"resType" : @"optPair",
            @"datas" : mt_PostArr
        };
        
        
        [Inc_NewMB_HttpModel HTTP_NewMB_ModifiWithURL:@"unionEqpApi/updateUnionEqp"
                                                 Dict:modifiPostDict
                                              success:^(id  _Nonnull result) {
            if (success) {
                success(@{});
            }
        }];
        
        
    }];
    
}

@end
