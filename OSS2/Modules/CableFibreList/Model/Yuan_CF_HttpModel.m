//
//  Yuan_CF_HttpModel.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/21.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_CF_HttpModel.h"
#import "Http.h"
#import "Yuan_WebService.h"

#import "Yuan_CFConfigVM.h"


@implementation Yuan_CF_HttpModel


#pragma mark -  通过光缆段Id 获取纤芯列表  ---

+ (void) Http_CableFilberListRequestWithCableId:(NSString *)cableId
                                        Success:(void(^)(NSArray * data))success {
    
    Yuan_WebService * webService = Yuan_WebService.alloc.init;
    
    NSMutableDictionary * parma = [NSMutableDictionary dictionary];
    
    NSString * url = [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,selectOptPairB];
    
    if (!cableId || cableId.length == 0) {
        [[Yuan_HUD shareInstance] HUDFullText:@"缺少必要的光缆段ID"];
        return;
    }
    
    parma[@"optSectId"] = cableId;
    parma[@"reqDb"] = [webService webServiceGetDomainCode]; // 获取转码之后的reqDb
    
    [[Http shareInstance] POST:url dict:parma succeed:^(id data) {
       
        NSDictionary * requestData = data;
        
        if ([[requestData objectForKey:@"code"] isEqual:@200]) {
            
            NSArray * requestArray = [requestData objectForKey:@"data"];
            
            if (success && ![requestArray isEqual:[NSNull null]]) {
                
                success(requestArray);
            }
            
        }else {
            
            [[Yuan_HUD shareInstance] HUDFullText:requestData[@"msg"]];
        }
        
        
        
    }];
    
}


#pragma mark -  初始化纤芯  ---


+ (void) HttpFiberWithDict:(NSMutableDictionary *)parma
                   success:(void(^)(NSArray * data))success {
    
//    //龙哥服务
//    [[Http shareInstance] V2_POST:CF_HTTP_InitFiber
//                             dict:parma
//                          succeed:^(id data) {
//
//        if (success) {
//            success(data);
//        }
//
//    }];
  
    //使用重新初始化替换
    NSString * url = [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,reInitFibers];
    
    
    [Http.shareInstance DavidJsonPostURL:url
                                   Parma:parma
                                 success:^(id result) {
            
        NSDictionary * data = result;
        
        NSNumber * status = data[@"status"];
        
        if (success) {
            
            switch (status.intValue) {
                case 0:
                    [YuanHUD HUDFullText:@"修改纤芯数与实际纤芯数相同"];
                    break;
                    
                case 1:
                    [YuanHUD HUDFullText:@"初始化成功"];
                    success(result);
                    break;
                    
                case 2:
                    [YuanHUD HUDFullText:@"初始化失败"];
                    break;
                    
                    
                case 4:
                    [YuanHUD HUDFullText:@"实际纤芯数量和光缆段中纤芯数量不符 同步光缆段中纤芯数量 失败"];
                    break;
                    
                case 5:
                    [YuanHUD HUDFullText:@"实际纤芯数量大于光缆段要修改纤芯数量 且删除纤芯有成端关系"];
                    break;
                    
                case 6:
                    [YuanHUD HUDFullText:@"未查到光缆段"];
                    break;
                    
                default:
                    [YuanHUD HUDFullText:[NSString stringWithFormat:@"未知原因状态 %@",status]];
                    break;
            }
        }
        
    }];
    
}



#pragma mark -  通过光缆接头的Id 去查询关联的光缆段  ---

+ (void) HttpCableStart_Type:(NSString *) startType
                  Start_Id:(NSString *) startId
                     success:(void(^)(NSArray * data))success {
    
    
    NSMutableDictionary * parma = [NSMutableDictionary dictionary];
    
    parma[@"resLogicName"] = @"cable";
    parma[@"cableStart_Type"] = startType;
    parma[@"cableStart_Id"] = startId;
    
    [[Http shareInstance] V2_POST:CF_HTTP_ConnectSearchCableList
                             dict:parma
                          succeed:^(id data) {
        
        if (success) {
            success(data);
        }
        
    }];
    
}


#pragma mark -  保存  ---


/// 支持一次多发
/// @param saveMsgArray 存放每个map的数组
/// @param success 回调
+ (void) HttpCableFiberSaveSuccess:(void(^)(NSArray * data))success {
    
    
    
    Yuan_CFConfigVM * viewModel = Yuan_CFConfigVM.shareInstance;
    
    // 获取最原始的array
    NSArray * WDW_httpPort_Arr = viewModel.WDW_Port_Array;
    
    
    NSMutableArray * yuan_HTTP_PostArr = [NSMutableArray arrayWithArray:viewModel.linkSaveHttpArray];
    
    
    
    for (NSMutableDictionary * Yuan_Connect_Dict in yuan_HTTP_PostArr) {
          
        // 证明 关联的是我当前光缆段内的 第几个纤芯
        NSString * pairNo = Yuan_Connect_Dict[@"pairNo"];
        
//        NSString * yuan_ConnectDict_Location = Yuan_Connect_Dict[@"location"];
        
        NSMutableArray * optConjunctions_mtArr = [Yuan_Connect_Dict[@"optConjunctions"] mutableCopy];
        
        NSDictionary * optConjuctions_dict = optConjunctions_mtArr.firstObject;
        
        NSString * yuan_ConnectDict_Location = optConjuctions_dict[@"location"];
        
        
        for (NSDictionary * wdw_dict in WDW_httpPort_Arr) {
            
            if ([wdw_dict[@"pairNo"] isEqualToString:pairNo]) {
                
                
                NSArray * connectList = wdw_dict[@"connectList"];
                NSString * pairID = wdw_dict[@"pairId"];
                NSString * pairName = wdw_dict[@"pairName"];
                
                for (NSDictionary * singleDict in connectList) {
                    
                    // 转 王大为的dict 改成 龙哥的dict
                 NSDictionary * newPostDict =
                    [Yuan_CF_HttpModel WDW_DictTo_OptConjunctions_Dict:singleDict
                                                                pairId:pairID
                                                              pairName:pairName];
                   
                    // 判断location 字段 是不是相同 , 相同不用管 , 找那个不同的.
                    NSString * newDict_Location = newPostDict[@"location"];
                    
                    if (([yuan_ConnectDict_Location isEqualToString:@"start"] &&
                         [newDict_Location isEqualToString:@"end"]) ||
                        ( [yuan_ConnectDict_Location isEqualToString:@"end"] &&
                         [newDict_Location isEqualToString:@"start"])) {
                        
                        [optConjunctions_mtArr addObject:newPostDict];
                    }else {
                        continue;
                    }
                    
                }
                
            }
            
        }
        
        
        // 再把填充完的数组 覆盖之前的数组
        Yuan_Connect_Dict[@"optConjunctions"] = optConjunctions_mtArr;
        
    }
    
    
    
    
    
    [[Http shareInstance] V2_POST_SendMore:CF_HTTP_ConfigSave
                                     array:yuan_HTTP_PostArr
                                   succeed:^(id data) {
        
        if (success) {
            [[Yuan_HUD shareInstance] HUDFullText:@"保存成功"];
            success(data);
        }
        
    }];
    
    
}




+ (NSDictionary *) WDW_DictTo_OptConjunctions_Dict:(NSDictionary *)WDW_Dict
                                            pairId:(NSString *) pairId
                                          pairName:(NSString *)pairName{
    
    

    // 光缆段的起始和终止的设备名称  用于和纤芯去判断
    
    Yuan_CFConfigVM * viewModel = Yuan_CFConfigVM.shareInstance;
    
    // cableEnd_Id cableStart_Id
    NSString * cableStart_Id = viewModel.moBan_Dict[@"cableStart_Id"];
    NSString * cableEnd_Id = viewModel.moBan_Dict[@"cableEnd_Id"];
    
    NSString * resAId = WDW_Dict[@"resAId"] ?: @"";
    NSString * resBId = WDW_Dict[@"resBId"] ?: @"";

    // 只有熔接才有
    NSString * tieInName = WDW_Dict[@"tieInName"] ?: @"";
    NSString * tieInId = WDW_Dict[@"tieInId"] ?: @"";
    
    NSString * superResName = WDW_Dict[@"superResName"] ?: @"";
    NSString * superResId = WDW_Dict[@"superResId"] ?: @"";
    
    
    // 如果 resAId 或者 resBId 与 pairId 相同的那一组 弃用


    NSString * resId = @"";    //端子或者对端光缆段的Id , 用于下方view 验证
    NSString * resName = @"";
    NSString * resType = @"";
    NSString * location = @"" ;
    
    NSString * A_Or_B = @"" ;
    

    if (![resAId isEqualToString:pairId]) {
        
        resName = WDW_Dict[@"resAName"];
        resId = WDW_Dict[@"resAId"];
        resType = WDW_Dict[@"resATypeId"];
        A_Or_B = @"A";
    }else if (![resBId isEqualToString:pairId]) {
        
        resName = WDW_Dict[@"resBName"];
        resId = WDW_Dict[@"resBId"];
        resType = WDW_Dict[@"resBTypeId"];
        A_Or_B = @"B";
    }else {
        resName = @"";
        resId = @"";
        resType = @"";
        A_Or_B = @"";
    }
    
    
    
    if (tieInName.length > 0 && tieInId.length > 0) {
        
        // 熔接状态下
        if ([tieInId rangeOfString:cableStart_Id].location != NSNotFound) {
            // 证明是熔接是起始设备
            location = @"start";
        }else if([tieInId rangeOfString:cableEnd_Id].location != NSNotFound){
            location = @"end";
        }
        
    }

    if (superResName.length > 0 && superResId.length > 0) {
        
        // 成端状态下
        if ([superResId rangeOfString:cableStart_Id].location != NSNotFound) {
            // 证明是熔接是起始设备
            location = @"start";
        }else if([superResId rangeOfString:cableEnd_Id].location != NSNotFound){
            location = @"end";
        }
        
    }
    
    
    
    
    
    NSMutableDictionary * dictionary = NSMutableDictionary.dictionary;
    
    dictionary[@"resLogicName"] = @"optConjunction";
    dictionary[@"resA_Type"] = @"1";
    dictionary[@"resB_Type"] = [resType isEqualToString:@"317"] ? @"2" : @"1";
    dictionary[@"resA_Id"] = pairId;
    dictionary[@"resB_Id"] = resId;
    dictionary[@"resAEqp_Id"] = viewModel.moBan_Dict[@"GID"] ?: @"";
    dictionary[@"location"] = location;
    
    // cableEnd_Id cableStart_Id
    if ([location isEqualToString:@"start"]) {
        // 证明 与起始设备相连
        dictionary[@"resZEqp_Id"] = viewModel.moBan_Dict[@"cableStart_Id"];
    }else if([location isEqualToString:@"end"]) {
        dictionary[@"resZEqp_Id"] = viewModel.moBan_Dict[@"cableEnd_Id"];
    }else {
        
    }
    
    
    
    
    
    
    return dictionary;
}



#pragma mark -  撤销绑定  ---


/// 撤销起始设备  -- 把撤销的屏蔽掉 , 把未撤销的通过保存 发送到保存接口中 .
+ (void) HttpCableFiberDelete_StartDeviceWithDict:(NSDictionary *)WDW_Dict
                                          Success:(void(^)(void))success {
    
    NSMutableDictionary * PostDict = [NSMutableDictionary dictionaryWithDictionary:WDW_Dict];
    
    
    NSArray * connectList = WDW_Dict[@"connectList"];
    NSString * pairID = WDW_Dict[@"pairId"];
    NSString * pairName = WDW_Dict[@"pairName"];
    
    BOOL isHaveStart = NO;
    
    for (NSDictionary * singleDict in connectList) {
        
        // 转 王大为的dict 改成 龙哥的dict
     NSDictionary * newPostDict =
        [Yuan_CF_HttpModel WDW_DictTo_OptConjunctions_Dict:singleDict
                                                    pairId:pairID
                                                  pairName:pairName];
       // start 重点!!!
        if ([newPostDict[@"location"] isEqualToString:@"start"]) {
            isHaveStart = YES;
            continue;
        }
        
        else {
            // 只传终止端
            PostDict[@"optConjunctions"] = @[newPostDict];
        }
        
    }
    
    NSMutableArray * postArr = NSMutableArray.array;
    [postArr addObject:PostDict];
    
    
    if (!isHaveStart) {
        [[Yuan_HUD shareInstance] HUDFullText:@"当前未绑定起始设备"];
        return;
    }
    
    if (![PostDict.allKeys containsObject:@"optConjunctions"]) {
        PostDict[@"optConjunctions"] = @[];
    }
    
    [[Http shareInstance] V2_POST_SendMore:CF_HTTP_ConfigSave
                                     array:postArr
                                   succeed:^(id data) {
        
        if (success) {
            [[Yuan_HUD shareInstance] HUDFullText:@"撤销成功"];
            success();
        }
        
    }];
    
    
    
}


/// 撤销终止设备 -- 把撤销的屏蔽掉 , 把未撤销的通过保存 发送到保存接口中 .
+ (void) HttpCableFiberDelete_EndDeviceWithDict:(NSDictionary *)WDW_Dict
                                        Success:(void(^)(void))success {
    
    NSMutableDictionary * PostDict = [NSMutableDictionary dictionaryWithDictionary:WDW_Dict];
    
    
    NSArray * connectList = WDW_Dict[@"connectList"];
    NSString * pairID = WDW_Dict[@"pairId"];
    NSString * pairName = WDW_Dict[@"pairName"];
    
    BOOL isHaveEnd = NO;
    
    for (NSDictionary * singleDict in connectList) {
        
        // 转 王大为的dict 改成 龙哥的dict
     NSDictionary * newPostDict =
        [Yuan_CF_HttpModel WDW_DictTo_OptConjunctions_Dict:singleDict
                                                    pairId:pairID
                                                  pairName:pairName];
       
        // end 重点!!!
        if ([newPostDict[@"location"] isEqualToString:@"end"]) {
            isHaveEnd = YES;
            continue;
        }
        
        else {
            // 只传起始端
            PostDict[@"optConjunctions"] = @[newPostDict];
        }
        
    }
    
    NSMutableArray * postArr = NSMutableArray.array;
    [postArr addObject:PostDict];
    
    
    if (!isHaveEnd) {
        [[Yuan_HUD shareInstance] HUDFullText:@"当前未绑定终止设备"];
        return;
    }
    
    if (![PostDict.allKeys containsObject:@"optConjunctions"]) {
        
        PostDict[@"optConjunctions"] = @[];
    }
    
    
    
    
    
    
    [[Http shareInstance] V2_POST_SendMore:CF_HTTP_ConfigSave
                                     array:postArr
                                   succeed:^(id data) {
        
        if (success) {
            [[Yuan_HUD shareInstance] HUDFullText:@"撤销成功"];
            success();
        }
        
    }];
    
}



/// 新增 查看成端端子的关联关系
+ (void) HttpSelectFiberReleationShipWithTermIds:(NSString *)IDs
                                         Success:(void(^)(NSArray * data))success {
    
    
    Yuan_WebService * webService = Yuan_WebService.alloc.init;
    
    NSString * url = @"http://120.52.12.12:8951/increase-res-search/optRes/searchOptConjunctionByTermIds";
    
    NSMutableDictionary * mt_Dict = NSMutableDictionary.dictionary;
    mt_Dict[@"reqDb"] = [webService webServiceGetDomainCode];
    mt_Dict[@"termIds"] = IDs;
    
    [[Http shareInstance] POST:url
                          dict:mt_Dict
                       succeed:^(id data) {
        
        NSNumber * code = data[@"code"];
        
        if (code.intValue == 200) {
            
            NSArray * datas = data[@"data"];
            
            if ([datas isEqual:[NSNull null]]) {
                return ;
            }
            
            if (success) {
                success(datas);
            }
            
        }
        
    }];
    
}

#pragma mark - 2021-08-02 ---

/// 重新初始化纤芯
+ (void) HttpReInit_Fibers:(NSDictionary *) dict
                   Success:(void(^)(id result))success {
    
    NSString * url = [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,reInitFibers];
    
    
    [Http.shareInstance DavidJsonPostURL:url
                                   Parma:dict
                                 success:^(id result) {
            
        NSDictionary * data = result;
        
        NSNumber * status = data[@"status"];
        
        if (success) {
            
            switch (status.intValue) {
                case 0:
                    [YuanHUD HUDFullText:@"修改纤芯数与实际纤芯数相同"];
                    break;
                    
                case 1:
                    [YuanHUD HUDFullText:@"初始化成功"];
                    success(result);
                    break;
                    
                case 2:
                    [YuanHUD HUDFullText:@"初始化失败"];
                    break;
                    
                    
                case 4:
                    [YuanHUD HUDFullText:@"实际纤芯数量和光缆段中纤芯数量不符 同步光缆段中纤芯数量 失败"];
                    break;
                    
                case 5:
                    [YuanHUD HUDFullText:@"实际纤芯数量大于光缆段要修改纤芯数量 且删除纤芯有成端关系"];
                    break;
                    
                case 6:
                    [YuanHUD HUDFullText:@"未查到光缆段"];
                    break;
                    
                default:
                    [YuanHUD HUDFullText:[NSString stringWithFormat:@"未知原因状态 %@",status]];
                    break;
            }
        }
        
    }];
    
}



#pragma mark - 2022-02-14 ---

/// 批量对纤芯删除 成端熔接关系
+ (void) HttpBatchDeleteReleationShips:(NSArray *) conjunctionList
                               success:(httpSuccessBlock)success {
    
    
    
    
    NSString * url =
    [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,_batchDeleteReleationShips];
    
    [Http.shareInstance DavidJsonPostURL:url
                                   Parma:@{@"conjunctionList" : conjunctionList}
                                 success:^(id result) {
        
        success(result);
        
    }];
    
}



@end
