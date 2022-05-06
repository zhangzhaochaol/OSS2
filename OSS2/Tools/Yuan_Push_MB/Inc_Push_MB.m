//
//  Inc_Push_MB.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/11/5.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_Push_MB.h"

#import "ResourceTYKListViewController.h"       //统一库 通用搜索
#import "StationSelectResultTYKViewController.h"    //统一库回调搜索

#import "CableTYKViewController.h"


#import "Inc_NewMB_HttpModel.h"

@implementation Inc_Push_MB



#pragma mark -  跳转到通用模板   ---
///// 无数据时跳转
+ (void) PushOldMB_FromResLogicName:(NSString *)resLogicName
                                Gid:(NSString *)GID
                                 vc:(UIViewController *)vc{

    if (!resLogicName || !GID) {
        [YuanHUD HUDFullText:@"缺少必要的参数"];
        return;
    }


    [Http.shareInstance V2_POST:HTTP_TYK_Normal_Get
                           dict:@{@"resLogicName" : resLogicName,
                                  @"GID" : GID}
                        succeed:^(id data) {

        NSArray * result = data;

        if (result.count == 0) {
            [YuanHUD HUDFullText:@"未获取到数据"];
            return;
        }

        NSDictionary * dict = result.firstObject;

        if (!dict || [dict obj_IsNull]) {
            [YuanHUD HUDFullText:@"数据错误"];
            return;
        }

        [Inc_Push_MB pushFrom:vc
                  resLogicName:resLogicName
                          dict:dict
                          type:TYKDeviceListUpdate];


    }];
}



/// 有数据时跳转
+ (TYKDeviceInfoMationViewController *) pushFrom:(UIViewController *)vc
                                    resLogicName:(NSString * _Nonnull)resLogicName
                                            dict:(NSDictionary * _Nonnull)dict
                                            type:(TYKDeviceListControlTypeRef)type{
    
    
    if (!resLogicName) {
        
        [[Yuan_HUD shareInstance] HUDFullText:@"缺少跳转模板必要的resLogicName"];
        
        return nil;
    }
    
    TYKDeviceInfoMationViewController *device =
    [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:type
                                                         withMainModel:nil
                                                         withViewModel:nil
                                                          withDataDict:dict
                                                          withFileName:resLogicName];
    
    Push(vc, device);
    
    return device;
}



//// 光缆段 特殊跳转
+ (TYKDeviceInfoMationViewController *) push_Cable_From:(UIViewController *)vc
                                                   dict:(NSDictionary * _Nonnull)dict
                                                   type:(TYKDeviceListControlTypeRef)type {




    IWPPropertiesReader * reader =
    [IWPPropertiesReader propertiesReaderWithFileName:@"cable"
                                withFileDirectoryType:IWPPropertiesReadDirectoryDocuments];

    IWPPropertiesSourceModel * model = [IWPPropertiesSourceModel modelWithDict:reader.result];

    // 创建viewModel
    NSMutableArray * arrr = [NSMutableArray array];
    for (NSDictionary * model_dict in model.view) {
        IWPViewModel * viewModel = [IWPViewModel modelWithDict:model_dict];
        [arrr addObject:viewModel];
    }

    NSArray <IWPViewModel *> * mb_Arr = arrr;

    TYKDeviceInfoMationViewController *device =
    [CableTYKViewController deviceInfomationWithControlMode:type
                                              withMainModel:model
                                              withViewModel:mb_Arr
                                               withDataDict:dict
                                               withFileName:@"cable"];

    Push(vc, device);


    return device;
}




#pragma mark -  资源列表  ---

+ (void)pushResourceTYKListFrom:(UIViewController *)vc
                       fileName:(NSString *)fileName
                       showName:(NSString *)showName{
    
    if (!fileName) {
        
        [[Yuan_HUD shareInstance] HUDFullText:@"缺少必要的fileName"];
        return;
    }
    

    
    
    
    
    ResourceTYKListViewController * resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
    
    resourceTYKListVC.fileName = fileName;
    resourceTYKListVC.showName = showName;
    
    Push(vc, resourceTYKListVC);
    
}





#pragma mark -  跳转到 通用选择列表 , 点击后返回map  ---


+ (void) chooseResource_PushFrom:(UIViewController *)vc
                    resLogicName:(NSString * _Nonnull)resLogicName
                           Block:(void(^)(NSDictionary * dict))block{

    StationSelectResultTYKViewController * result =
    [[StationSelectResultTYKViewController alloc] initWithResLogicName:resLogicName
                                                                 Block:^(NSDictionary *cableMsg) {
        if (block) {
            block(cableMsg);
        }
    }];


    Push(vc, result);
}



#pragma mark - 新模板 ---

/// 新模板详情
+ (Inc_NewMB_DetailVC *) push_NewMB_Detail_RequestDict:(NSDictionary *) requestDict
                                                  Enum:(Yuan_NewMB_ModelEnum_) Enum
                                                    vc:(UIViewController *) vc{
    
    
    Inc_NewMB_DetailVC * new_MB = [[Inc_NewMB_DetailVC alloc] initWithDict:requestDict
                                                        Yuan_NewMB_ModelEnum:Enum];
    
    Push(vc, new_MB);
    
    return new_MB;
}



/// 新模板详情列表
+ (void) push_NewMB_ListEnum:(Yuan_NewMB_ModelEnum_) Enum
                          vc:(UIViewController *) vc {
    
    Inc_NewMB_ListVC * list = [[Inc_NewMB_ListVC alloc] initWithModelEnum:Enum];
    
    Push(vc, list);
    
}



/// 新模板 根据id 查询详细信息
+ (void) NewMB_GetDetailDictFromGid:(NSString *) gid
                               Enum:(Yuan_NewMB_ModelEnum_) Enum
                            success:(void(^)(NSDictionary * dict)) success {
    
    Inc_NewMB_HttpPort * httpPortModel = [Inc_NewMB_HttpPort ModelEnum:Enum];
    
    NSString * type = httpPortModel.type;
    NSDictionary * postDict = @{
        @"id" : gid ?: @"",
        @"type" : type ?: @""
    };
    
    [Inc_NewMB_HttpModel HTTP_NewMB_SelectDetailsFromIdWithURL:httpPortModel.SelectFrom_IdType
                                                           Dict:postDict
                                                        success:^(id  _Nonnull result) {
                
        NSArray * resultArr = result;
        NSDictionary * dic = resultArr.firstObject;

        if (success) {
            success(dic);
        }
    }];
    
    
}




// 新模板 根据gid 直接查询详情 并且跳转详细信息页面
+ (void) NewMB_PushDetailsFromId:(NSString *) gid
                            Enum:(Yuan_NewMB_ModelEnum_) Enum
                              vc:(UIViewController *)vc{
    
    [Inc_Push_MB NewMB_GetDetailDictFromGid:gid
                                       Enum:Enum
                                    success:^(NSDictionary * _Nonnull dict) {
            
        Inc_NewMB_DetailVC * new_MB =
        [[Inc_NewMB_DetailVC alloc] initWithDict:dict
                            Yuan_NewMB_ModelEnum:Enum];
        
        Push(vc, new_MB);
    }];
    
}


// 新模板 根据gid 直接查询详情 并且跳转详细信息页面 并且有保存的回调
+ (void) NewMB_PushDetailsFromId:(NSString *) gid
                            Enum:(Yuan_NewMB_ModelEnum_) Enum
                              vc:(UIViewController *)vc
                       saveBlock:(void(^)(id result))saveBlock{
    
    [Inc_Push_MB NewMB_GetDetailDictFromGid:gid
                                       Enum:Enum
                                    success:^(NSDictionary * _Nonnull dict) {
            
        Inc_NewMB_DetailVC * new_MB =
        [[Inc_NewMB_DetailVC alloc] initWithDict:dict
                            Yuan_NewMB_ModelEnum:Enum];
        
        Push(vc, new_MB);
        
        new_MB.saveBlock = ^(NSDictionary * _Nonnull saveDict) {
          
            if (saveBlock) {
                saveBlock(saveDict);
            }
        };
        
    }];
    
}


@end
