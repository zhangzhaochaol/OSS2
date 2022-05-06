//
//  Inc_NewMB_HttpModel.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_NewMB_HttpModel.h"
#import "Inc_NewMB_Model.h"



@implementation Inc_NewMB_HttpModel

///MARK: 新模板界面 查询资源
+ (void) HTTP_NewMB_SelectWithURL:(NSString *)url
                             Dict: (NSDictionary *) dict
                           success:(void(^)(id result)) success {
    
    NSString * postUrl = [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,url];
    
    [Http.shareInstance DavidJsonPostURL:postUrl
                                   Parma:dict
                                 success:^(id result) {
       
        if (success) {
            success(result[@"content"]);
        }
    }];
}



/// 新模板界面 根据Id 查询资源详细信息
+ (void) HTTP_NewMB_SelectDetailsFromIdWithURL:(NSString *)url
                                          Dict: (NSDictionary *) dict
                                       success:(void(^)(id result)) success {
    
    
    NSString * postUrl = [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,url];
    
    [Http.shareInstance DavidJsonPostURL:postUrl
                                   Parma:dict
                                 success:^(id result) {
       
        if (success) {
            
            NSArray * arr = result;
            
            if (arr.count > 0) {
                success(arr);
            }
            else {
                [YuanHUD HUDFullText:@"未查询到该资源_Yuan"];
                return;
            }
            
            
        }
    }];
    
}





///MARK: 新模板界面 新增资源
+ (void) HTTP_NewMB_AddWithURL:(NSString *)url
                          Dict: (NSDictionary *) dict
                        success:(void(^)(id result)) success {
    
    NSString * postUrl = [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,url];
    
    [Http.shareInstance DavidJsonPostURL:postUrl
                                   Parma:dict
                                 success:^(id result) {
        if (success) {
            success(result);
        }
    }];
    
}



///MARK: 新模板界面 修改资源
+ (void) HTTP_NewMB_ModifiWithURL:(NSString *)url
                             Dict: (NSDictionary *) dict
                           success:(void(^)(id result)) success {
    
    NSString * postUrl = [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,url];
    
    [Http.shareInstance DavidJsonPostURL:postUrl
                                   Parma:dict
                                 success:^(id result) {
        if (success) {
            success(result);
        }
    }];
    
}



///MARK: 新模板界面 删除资源
+ (void) HTTP_NewMB_DeleteWithURL:(NSString *)url
                             Dict: (NSDictionary *) dict
                           success:(void(^)(id result)) success {
    
    
    NSString * postUrl = [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,url];
    
    [Http.shareInstance DavidJsonPostURL:postUrl
                                   Parma:dict
                                 success:^(id result) {
        if (success) {
            success(result);
        }
    }];
}




#pragma mark - 其他辅助接口 ---

/// 通过OLT的Id 查询所属OLT的全部端口
+ (void) HTTP_NewMB_SelectOLTPort_OLTId:(NSString *) OLT_Id
                                success:(void(^)(id result)) success {
    
    if (!OLT_Id) {
        [YuanHUD HUDFullText:@"缺少olt_ID"];
        return;
    }
    
    NSString * postUrl = [NSString stringWithFormat:@"%@eqpResApi/findRmePortBySuperResId",Http.David_SelectUrl];
    
    NSDictionary * dict = @{@"id":OLT_Id ,
                            @"type":@"2510"};
    
    [Http.shareInstance DavidJsonPostURL:postUrl
                                   Parma:dict
                                 success:^(id result) {
        if (success) {
            success(result);
        }
    }];
    
}



/// 获取所属维护区域
+ (void) HTTP_NewMB_RegionListSuccess:(void(^)(id result)) success {
    
    
    NSString * postUrl = [NSString stringWithFormat:@"%@spcApi/findProvinceRegion",Http.David_SelectUrl];
    
    NSDictionary * dict = @{@"reqDb":Yuan_WebService.webServiceGetDomainCode};
        
    
    [Http.shareInstance POST:postUrl
                        dict:dict
                     succeed:^(id data) {
    
        NSNumber * code = data[@"code"];
        
        if (code.intValue == 200) {
            
            NSArray * datas = data[@"data"];
            
            if (success) {
                success(datas);
            }
        }
    }];
}



/// 根据省份获取 生产厂家列表
+ (void) HTTP_NewMB_ManufacturerList_Success:(void(^)(id result)) success {
    
    NSString * postUrl = [NSString stringWithFormat:@"%@pubApi/findMfrByPage",Http.David_SelectUrl];
    
    
    NSDictionary * dict = @{
            @"reqDb":Yuan_WebService.webServiceGetDomainCode,
            @"pageSize" : @"-1",
            @"pageNum" : @"-1"
    };
        
    
    [Http.shareInstance DavidJsonPostURL:postUrl
                                   Parma:dict
                                 success:^(id result) {
            
        if (success) {
            success(result[@"content"]);
        }
        
    }];
    
    
    
}


// 维护单位
+ (void) HTTP_NewMB_MaintainUnitList_Success:(void(^)(id result)) success {
    
    NSString * postUrl = [NSString stringWithFormat:@"%@unionSearch/unionSearchPubUnit",Http.David_SelectUrl];
    
    
    NSDictionary * dict = @{
            @"reqDb":Yuan_WebService.webServiceGetDomainCode,
    };
        
    
    [Http.shareInstance DavidJsonPostURL:postUrl
                                   Parma:dict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
        
    }];
    
}



// 根据扫一扫 rfid , 获取资源类型和Id
+ (void) HTTP_NewMB_Rfid:(NSString *)rfid Success:(void(^)(id result)) success {
    
    
    NSString * postUrl = [NSString stringWithFormat:@"%@pubApi/scanQrCode",Http.David_SelectUrl];
    
    NSDictionary * dict = @{@"reqDb":Yuan_WebService.webServiceGetDomainCode ,
                            @"code" : rfid};
    
    [Http.shareInstance DavidJsonPostURL:postUrl
                                   Parma:dict
                                 success:^(id result) {
       
        if (!result) {
            
            [UIAlert alertSmallTitle:@"未查询到相关资源信息" agreeBtnBlock:^(UIAlertAction *action) {
               
                if (success) {
                    success(@{});
                }
                
            }];
            return;
        }
        
        else {
            NSDictionary * dic = result;
            if (success) {
                success(dic);
            }
        }
    }];
}




/// 新模板 保存Rfid字段的单独接口
+ (void) HTTP_NewMB_SourceAdddigCodeDict:(NSDictionary *)dict
                                     Url:(NSString *) url
                                 Success:(void(^)(id result)) success {

    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,url];
    
    [Http.shareInstance DavidJsonPostURL:URL
                                   Parma:dict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
}



/// 新模板 查询分光器下属端子详情
+ (void) HTTP_NewMB_SelectDetailsFromOBD_PortWithURL:(NSString *)url
                                                Dict:(NSDictionary *) dict
                                             success:(void(^)(id result)) success {
    
    
    NSString * postUrl = [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,url];
    
    [Http.shareInstance DavidJsonPostURL:postUrl
                                   Parma:dict
                                 success:^(id result) {
       
        if (success) {
            
            NSArray * arr = result;
            
            if (arr.count > 0) {
                success(arr);
            }
            else {
                [YuanHUD HUDFullText:@"未查询到该资源_Yuan"];
                return;
            }
            
            
        }
    }];
    
}


@end
