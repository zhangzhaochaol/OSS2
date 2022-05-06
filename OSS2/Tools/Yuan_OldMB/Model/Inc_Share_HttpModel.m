//
//  Inc_Share_HttpModel.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/7/14.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_Share_HttpModel.h"



// 查看分享列表
static NSString * http_GetShareNotiListPort = @"pub/findShareList";

// 转发
static NSString * http_ForwardingPort = @"pub/addForward";

// 执行
static NSString * http_UpDataPort = @"pub/updateStateShare";

@implementation Inc_Share_HttpModel

/// 查询是否有新分享推送的接口
+ (void) http_SelectShareNotis:(NSDictionary *) parma
                       success:(void(^)(id result)) success {
    
    
    NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:parma];
    
    mt_Dict[@"numPage"] = @"-1";
    mt_Dict[@"numSiz"] = @"-1";
    mt_Dict[@"shareUserName"] = UserModel.userName;
    mt_Dict[@"reqDb"] = Yuan_WebService.webServiceGetDomainCode;
    
    [Http.shareInstance DavidJson_NOHUD_PostURL:[Inc_Share_HttpModel configURL:http_GetShareNotiListPort]
                                          Parma:mt_Dict
                                        success:^(id result) {
            
        if (success) {
            success(result);
        }
        
    }];
}


/// 查询分享列表
+ (void) http_SelectShareList:(NSDictionary *) parma
                      success:(void(^)(id result)) success {
    
    NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:parma];
    
    mt_Dict[@"numPage"] = @"-1";
    mt_Dict[@"numSiz"] = @"-1";
    mt_Dict[@"shareUserName"] = UserModel.userName;
    mt_Dict[@"reqDb"] = Yuan_WebService.webServiceGetDomainCode;
    
    [Http.shareInstance DavidJsonPostURL:[Inc_Share_HttpModel configURL:http_GetShareNotiListPort]
                                   Parma:mt_Dict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
}


/// 查询路由详情
+ (void) http_SelectRouterFromRoute:(NSString *) targetId
                            success:(void(^)(id result)) success {
    

    
    [Http.shareInstance GET:@"http://120.52.12.12:8951/increase-res-fiber/plan/list/by/targetId"
                       dict:@{@"targetId":targetId ,
                              @"sortType":@"1"}
                    succeed:^(id data) {
            
        if (success) {
            
            NSDictionary * dict = data;
            
            NSNumber * code = dict[@"code"];
            
            if (code.intValue == 200) {
                success(dict[@"data"]);
            }
        }
    }];

}


/// 转发
+ (void) http_ForwardingFromParam:(NSDictionary *) parma
                          success:(void(^)(id result)) success {
    
    
    
    NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:parma];
    mt_Dict[@"reqDb"] = Yuan_WebService.webServiceGetDomainCode;

    
    [Http.shareInstance DavidJsonPostURL:[Inc_Share_HttpModel configURL:http_ForwardingPort]
                                   Parma:mt_Dict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
}


/// 执行
+ (void) http_UpDataFromParam:(NSDictionary *) parma
                      success:(void(^)(id result)) success {
    
    
    
    NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:parma];
    mt_Dict[@"reqDb"] = Yuan_WebService.webServiceGetDomainCode;

    
    [Http.shareInstance DavidJsonPostURL:[Inc_Share_HttpModel configURL:http_UpDataPort]
                                   Parma:mt_Dict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
}


+ (NSString *) configURL:(NSString *) url {
    
    return David_ModifiUrl(url);
}

@end
