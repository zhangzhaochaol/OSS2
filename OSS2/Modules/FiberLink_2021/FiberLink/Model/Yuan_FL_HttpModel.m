//
//  Yuan_FL_HttpModel.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/12/1.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_FL_HttpModel.h"
#import "Yuan_WebService.h"

@implementation Yuan_FL_HttpModel

// 获取局向光纤资源
+ (void) HTTP_FL_GetOpticalFiber:(NSDictionary *)dict
                         success:(void(^)(id result))success {
    
    NSString * reqDb = [[[Yuan_WebService alloc] init] webServiceGetDomainCode];
    
//    NSString * reqDb = @"heilongjiang";

    NSMutableDictionary * paramDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    paramDict[@"reqDb"] = reqDb;
    
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,FL_OpticalFiberPort];
    
    [[Http shareInstance] DavidJsonPostURL:URL
                                     Parma:paramDict
                                   success:^(id result) {
       
        if (success) {
            success(result);
        }
        
    }];
}



// 获取光纤链路资源
+ (void) HTTP_FL_GetOpticalLink:(NSDictionary *)dict
                        success:(void(^)(id result))success {
    
    
    NSString * reqDb = [[[Yuan_WebService alloc] init] webServiceGetDomainCode];
    
//    NSString * reqDb = @"heilongjiang";

    NSMutableDictionary * paramDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    paramDict[@"reqDb"] = reqDb;
    
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,FL_OpticalLinkPort];
    
    [[Http shareInstance] DavidJsonPostURL:URL
                                     Parma:paramDict
                                   success:^(id result) {
       
        if (success) {
            success(result);
        }
        
    }];
    
}


+ (void) HTTP_FL_GetResWithDict:(NSDictionary *)dict
                        success:(void(^)(id result))success {
    
    
    
    [[Http shareInstance] V2_POST:HTTP_TYK_Normal_Get
                             dict:[dict mutableCopy]
                          succeed:^(id data) {
        
        if (success) {
            success(data);
        }
        
    }];
    
}


@end
