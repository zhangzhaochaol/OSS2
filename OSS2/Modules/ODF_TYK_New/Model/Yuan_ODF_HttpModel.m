//
//  Yuan_ODF_HttpModel.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/6/1.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_ODF_HttpModel.h"

#import "Yuan_ODFLimitModel.h"   /// limit Model


/// 2021-08-02 新增 , 大为新接口 根据设备或模块 查询端子
static NSString * _NewPort_SelectTerminals = @"res/getPortsByEqpId";

/// 2021-08-02 新增 , 大为新接口 根据设备或模块 查询端子
static NSString * _NewPort_BatchSynchronizeTerminalStatus = @"eqpApi/batchUpdateTermOprState";


/// 2022-03-11, 替换通用查询分光器   目前端子盘查询分光器使用
static NSString * findOptResList = @"optRes/findOptResList";

/// 2022-04-09, 郑小英新的初始化模块
static NSString * _NewPort_InitModule = @"lineApi/initModuleAndOpticTerm";


@implementation Yuan_ODF_HttpModel

#pragma mark - 请求列表信息

+ (void) ODF_HttpGetLimitDataWithID:(NSString *)gid
                           InitType:(NSString *)type
                       successBlock:(void(^)(id requestData))success {
    
    
    // 150003020000001256128868
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    
    // 前三个是固定的
    dict[@"limit"] = @"100";
    dict[@"start"] = @"1";
    dict[@"resLogicName"] = @"cnctShelf";
    
    // 第四个是根据传入的i d判断
    
    if ([type isEqualToString:@"1"]) {
        //ODF
        dict[@"rackName_Id"] = gid;
    }else if([type isEqualToString:@"2"]){
        //OCC
        dict[@"eqpId_Id"] = gid;
        dict[@"eqpId_Type"] = type;
    }else if ([type isEqualToString:@"3"]) {
        //ODB
        dict[@"eqpId_Id"] = gid;
        dict[@"eqpId_Type"] = type;
    }
    else if ([type isEqualToString:@"4"]) {
        //OBD 
        dict[@"eqpId_Id"] = gid;
        dict[@"eqpId_Type"] = type;
    }
    
    
    
    [[Http shareInstance] V2_POST:ODFModel_GetLimitData
                             dict:dict
                          succeed:^(id data) {
       
        NSArray * dataSource = data;
 
        
        if ([dataSource isEqual:[NSNull null]]) {
            
            [[Yuan_HUD shareInstance] HUDFullText:@"数据格式错误 NULL"];
            return ;
        }
        
        success(dataSource);
        
    }];
    
}



#pragma mark - 初始化端子盘信息
/// 初始化 盘
/// @param dict dict
/// @param success 回调
+ (void) ODF_HttpInitDict:(NSDictionary *)dict
             successBlock:(void(^)(id requestData))success {
    
    
    NSLog(@"dict - %@",dict);
    NSArray * ruleDire_Arr = [dict[@"Rule_Dire"] componentsSeparatedByString:@"、"];
    
    NSString * rule = [ruleDire_Arr firstObject];   // 行优 列优
    NSString * dire = [ruleDire_Arr lastObject];    // 方向
    
    
    
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    
    
    dictionary[@"resLogicName"] = @"cnctShelf";

    
    
    
    dictionary[@"eqpId"] = dict[@"equName"];                               // 虽然参数叫 Id  但 传的是name
    dictionary[@"eqpId_Type"] = dict[@"eqpId_Type"];
    dictionary[@"eqpId_Id"] = dict[@"eqpId_Id"];                              //设备Id
    
    dictionary[@"position"] = dict[@"position"];
    dictionary[@"moduleRowQuantity"] = dict[@"moduleRowQuantity"];         //模块行数
    dictionary[@"moduleColumnQuantity"] = dict[@"moduleColumnQuantity"];   //模块列数
    dictionary[@"moduleTubeColumn"] = dict[@"moduleTubeColumn"];           //模块端子数量列数
    dictionary[@"moduleTubeRow"] = dict[@"moduleTubeRow"];                 //过去固定是1,现在是动态的
    dictionary[@"faceInverse"] = dict[@"faceInverse"];              //1 正面 2 反面
    
    
    dictionary[@"noRule"] = [Yuan_ODF_HttpModel ruleType:rule];
    dictionary[@"noDire"] = [Yuan_ODF_HttpModel direType:dire];
    
    NSLog(@"%@",dictionary);
    
    [[Http shareInstance] V2_POST:ODFModel_InitPie
                             dict:dictionary
                          succeed:^(id data) {
       
        
        NSArray * dataSource = data;
        
        if ([dataSource isEqual:[NSNull null]]) {

            [[Yuan_HUD shareInstance] HUDFullText:@"数据格式错误 NULL"];
            return ;
        }
        success(dataSource);
    }];
    
}


#pragma mark - 郑小英新的 初始化模块 ---
+ (void) ODF_HttpNewInitModuleWithDict:(NSDictionary *)dict
                               success:(httpSuccessBlock)success {
    
    NSLog(@"dict - %@",dict);
    NSArray * ruleDire_Arr = [dict[@"Rule_Dire"] componentsSeparatedByString:@"、"];
    
    NSString * rule = [ruleDire_Arr firstObject];   // 行优 列优
    NSString * dire = [ruleDire_Arr lastObject];    // 方向
    
    
    
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    
    
    // 行优列优 和 方向
    NSString * modelNoRule = @"3140001";
    if ([[Yuan_ODF_HttpModel ruleType:rule] isEqualToString:@"2"]) {
        modelNoRule = @"3140002";
    }
    
    NSString * modelNoDire = @"";
    
    switch ([Yuan_ODF_HttpModel direType:dire].intValue) {
        
        case 1: //上左
            modelNoDire = @"3140201";
            break;
            
        case 2: //上右
            modelNoDire = @"3140202";
            break;
            
        case 3: //下左
            modelNoDire = @"3140203";
            break;
            
        case 4: //下右
            modelNoDire = @"3140204";
            break;
            
        default:
            break;
    }
    

    dictionary[@"faceInverse"] = dict[@"faceInverse"];
    
    // 设备类型id  选择的设备类型 ODF_Equt：302   OCC_Equt：703  ODB_Equt：704   joint:705
    NSString * eqpTypeId = @"";
    
    switch ([dict[@"eqpId_Type"] intValue]) {
        case 1:
            eqpTypeId = @"302";
            break;
            
        case 2:
            eqpTypeId = @"703";
            break;
            
        case 3:
            eqpTypeId = @"704";
            break;
        
        case 4:
            eqpTypeId = @"705";
            break;
            
        default:
            break;
    }
    


    
    dictionary[@"eqpId"] = dict[@"eqpId_Id"];           //所属设备id
    dictionary[@"eqpTypeId"] = eqpTypeId;     //所属设备类型id
    
    NSString * name = [NSString stringWithFormat:@"%@.F%@",dict[@"equName"],dict[@"position"]];
    
    if (![dict[@"faceInverse"] isEqualToString:@"1"]) {
        name = [NSString stringWithFormat:@"%@/B.F%@",dict[@"equName"],dict[@"position"]];
    }
    
    dictionary[@"name"] = name;             //新建的模块名称
    dictionary[@"no"] = name;               //新建的模块no 与名称一致
    dictionary[@"position"] = dict[@"position"];
    
    
    // 行优列优 上下左右
    dictionary[@"modelNoRule"] = modelNoRule;
    dictionary[@"modelNoDire"] = modelNoDire;
    
    NSString * noRule = @"3140101";
    NSString * noDire = @"3140201";
    
    dictionary[@"noRule"] = noRule;
    dictionary[@"noDire"] = noDire;
    
    // 个数
    dictionary[@"modelTotalRow"] = dict[@"moduleRowQuantity"];
    dictionary[@"modelTotalCol"] = dict[@"moduleColumnQuantity"];
    dictionary[@"totalCol"] = dict[@"moduleTubeColumn"];
    dictionary[@"totalRow"] = dict[@"moduleTubeRow"];
    
    
    
    
    
    
    [Http.shareInstance DavidJsonPostURL:David_ModifiUrl(_NewPort_InitModule)
                                   Parma:@{@"data" : dictionary}
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
        
    }];
    
    
}




#pragma mark - 删除端子盘信息
+ (void) ODF_HttpDeleteDict:(NSDictionary *)postDict
               successBlock:(void(^)(id requestData))success{
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    
    
    dict[@"resLogicName"] = postDict[@"resLogicName"];
    dict[@"GID"] = postDict[@"GID"];
    
    [[Http shareInstance] V2_POST:ODFModel_DeletePie dict:dict succeed:^(id data) {
        
        NSArray * dataSource = data;
               
        if ([dataSource isEqual:[NSNull null]]) {
           
            [[Yuan_HUD shareInstance] HUDFullText:@"数据格式错误 NULL"];
            return ;
        }
        success(dataSource);
        
    }];
    
}







#pragma mark - 请求端子盘内 详细信息

+ (void)ODF_HttpDetail_Dict:(NSDictionary *)postDict
               successBlock:(void(^)(id requestData))success {
    
    
    [[Http shareInstance] V2_POST:ODFModel_DetailData
                             dict:[postDict mutableCopy]
                          succeed:^(id data) {
            
        NSArray * dataSource = data;
               
        if ([dataSource isEqual:[NSNull null]]) {
           
            [[Yuan_HUD shareInstance] HUDFullText:@"数据格式错误 NULL"];
            return ;
        }
        success(dataSource);
        
    }];
    
}







/// 长按 创建模块信息
/// @param postDict 参数
/// @param success 回调
+ (void)ODF_HttpLongPressInitModuleDict:(NSDictionary *)postDict
                           successBlock:(void(^)(id requestData))success {
    
    
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithDictionary:postDict];
    
    [[Http shareInstance] V2_POST:ODFModel_LongPressTapInitModule
                             dict:dictionary
                          succeed:^(id data) {
        
        if (success) {
            
            NSArray * array = data;
            
            if (array && array.count > 0) {
                
                success([data firstObject]);
            } else {
                
                [[Yuan_HUD shareInstance] HUDFullText:@"发送请求成功 , 但返回数据异常"];
            }
            
        }
        
    }];
    
    
    
    
}











+ (NSString *)ruleType:(NSString *)rule {
    
    
    
    if (!rule) {
        return @"1"; //默认行优
    }
    
    
    if ([rule isEqualToString:@"行优"]) {
        return @"1";
    }
    
    if ([rule isEqualToString:@"列优"]) {
        return @"2";
    }
    
    return @"1";
    
}


+ (NSString *)direType:(NSString *)dire {
    
    
    
    if (!dire) {
        return @"1"; //默认上左
    }
    
    
    if ([dire isEqualToString:@"上左"]) {
        return @"1";
    }
    
    if ([dire isEqualToString:@"上右"]) {
        return @"2";
    }
    
    if ([dire isEqualToString:@"下左"]) {
        return @"3";
    }
    
    if ([dire isEqualToString:@"下右"]) {
        return @"4";
    }
    
    return @"1";
}



/// 图片识别接口 //
+ (void)ODF_HttpImageToUnion:(UIImage *)image
                successBlock:(void(^)(id requestData))success {
    
    
    /*
     photoFile=图片文件
     type=eqpOdfPort
     */
    
    
    [[Http shareInstance] V2_POST_Image:image
                                imgName:@""
                                    URL:[NSString stringWithFormat:@"%@",David_DeleteUrl(@"unionAiApi/uploadPhoto")]
                                  param:@{@"type":@"eqpOdfPort"}
                                succeed:^(id data) {
        
        if (success) {
            
            NSNumber * code = data[@"code"];
            if ([code isEqual:@200]) {
                success(data);
                
                [Http.shareInstance httpStatistic:@"unionAiApi/uploadPhoto" paramJson:@{}];
                
            }else {
                NSString * msg = data[@"msg"];
                [[Yuan_HUD shareInstance] HUDFullText:msg ?: @"上传失败"];
            }
        }
    }];
}



/// 图片识别接口 保存完成后 , 给统一库返回去   --- 端子批量修改 上报时调用
+ (void)ODF_HttpImageToUnionBatchHold_TxtCoordinated:(NSArray *) txtCoordinated
                                             base64Img:(NSString *)img
                                                matrix:(NSArray *)matrix
                                        matrixModified:(NSArray *)matrixModified
                                          successBlock:(void(^)(id requestData))success {
    
    
    
    NSMutableArray * mt_arr_TxtCoordinated = NSMutableArray.array;
    
    for (NSDictionary * dict in txtCoordinated) {
        
        NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:dict];
        mt_Dict[@"type"] = dict[@"class"];
        [mt_Dict removeObjectForKey:@"class"];
        
        [mt_arr_TxtCoordinated addObject:mt_Dict];
    }
    
    
    
    NSDictionary * goBackDict = @{
        @"txtCoordinated" : mt_arr_TxtCoordinated ?: @[],
        @"img" : img ?: @"",
        @"matrix" : matrix ?: @[] ,
        @"matrixModified" : matrixModified ?: @[],
        @"province" : Yuan_WebService.webServiceGetChineseName
    };
    

    //根据
    NSString * url = [NSString stringWithFormat:@"%@",David_DeleteUrl(@"unionAiApi/uploadFixResult")];
    

    [Http.shareInstance DavidJson_NOHUD_PostURL:url
                                          Parma:goBackDict
                                        success:^(id result) {

        if (success) {
            success(result);
        }

    }];
    
}



/// 图片识别接口 保存完成后 , 给统一库返回去   --- 端子识别 返回时调用
+ (void)ODF_HttpImageToUnionImageCheck_TxtCoordinated:(NSArray *) txtCoordinated
                                            base64Img:(NSString *)img
                                               matrix:(NSArray *)matrix
                                       matrixModified:(NSArray *)matrixModified
                                         successBlock:(void(^)(id requestData))success {
    
    
    
    NSMutableArray * mt_arr_TxtCoordinated = NSMutableArray.array;
    NSMutableArray * maps = NSMutableArray.array;
    
    for (NSArray * arr in txtCoordinated) {
        
        for (NSDictionary * dict in arr) {
            [maps addObject:dict];
        }
        
    }
    
    
    for (NSDictionary * dict in maps) {
        
        NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:dict];
        mt_Dict[@"type"] = dict[@"class"];
        [mt_Dict removeObjectForKey:@"class"];
        
        [mt_arr_TxtCoordinated addObject:mt_Dict];
    }
    
    
    
    NSDictionary * goBackDict = @{
        @"txtCoordinated" : mt_arr_TxtCoordinated ?: @[],
        @"img" : img ?: @"",
        @"matrix" : matrix ?: @[] ,
        @"matrixModified" : matrixModified ?: @[],
        @"province" : Yuan_WebService.webServiceGetChineseName
    };
    

    //根据
    NSString * url = [NSString stringWithFormat:@"%@",David_DeleteUrl(@"unionAiApi/uploadFixResult")];
    

    [Http.shareInstance DavidJson_NOHUD_PostURL:url
                                          Parma:goBackDict
                                        success:^(id result) {

        if (success) {
            success(result);
        }

    }];
    
}




// 修改端子状态
+ (void)ODF_HttpChangeTerminalState:(NSDictionary *)dict
                       successBlock:(void(^)(id requestData))success {
    
    [[Http shareInstance] V2_POST:HTTP_TYK_Normal_UpData
                             dict:dict
                          succeed:^(id data) {
            
        if (success) {
            success(data);
        }
        
    }];
    
}



+ (void) ODF_HttpChangeBatchHoldArray:(NSArray *)arr
                         successBlock:(void(^)(id requestData))success {
    
    
    [Http.shareInstance V2_POST_SendMore:HTTP_TYK_Normal_UpData
                                   array:arr
                                 succeed:^(id data) {
        if (success) {
            success(data);
        }
    }];
    
    
}



/// 2021-08-02 新增  郑小英接口 , 通过设备id 或 列框Id 查询下属端子盘端子
// 参数为 reqDb id type , 当没有type时默认的是根据列框id 查询 , 有type时 , 是根据设备查询
+ (void) http_NewPort_SelectTerminalsFromDict:(NSDictionary *)dict
                                 successBlock:(void(^)(id requestData))success {
    
    
    
    [Http.shareInstance DavidJsonPostURL:David_SelectUrl(_NewPort_SelectTerminals)
                                   Parma:dict
                                 success:^(id result) {
        
        if (success) {
            success(result);
        }
            
    }];
    
}


/// 新接口 批量修改端子状态
+ (void) http_BatchSynchronizeTerminalStatus:(NSDictionary *) dict
                                successBlock:(void(^)(id requestData))success {
    
    [Http.shareInstance DavidJsonPostURL:David_ModifiUrl(_NewPort_BatchSynchronizeTerminalStatus)
                                   Parma:dict
                                 success:^(id result) {
        
        if (success) {
            success(result);
        }
            
    }];
    
}



/// 2022-03-11, 替换通用查询分光器   目前端子盘查询分光器使用
+ (void) http_findOptResList:(NSDictionary *) dict
                                successBlock:(void(^)(id requestData))success {
    
    [Http.shareInstance DavidJsonPostURL:David_SelectUrl(findOptResList)
                                   Parma:dict
                                 success:^(id result) {
        
        if (success) {
            success(result);
        }
            
    }];
    
}

@end
