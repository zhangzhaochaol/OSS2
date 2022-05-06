//
//  Inc_PoleNewConfig_HttpModel.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/9/2.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_PoleNewConfig_HttpModel.h"

@implementation Inc_PoleNewConfig_HttpModel

/// 统一库通用资源查询
+ (void) http_GetDatas:(NSDictionary *) dict
               success:(void(^)(id result))success {
    
    [Http.shareInstance V2_POST_NoHUD:HTTP_TYK_Normal_Get
                                 dict:dict
                              succeed:^(id data) {
            
        if (success) {
            success(data);
        }
        
    }];
    
}



/// 统一库通用资源查询
+ (void) http_InsertDatas:(NSArray *) arr
                  success:(void(^)(id result))success {
    
    
    [Http.shareInstance V2_POST_SendMore:HTTP_TYK_Normal_Insert
                                   array:arr
                                 succeed:^(id data) {
                
        if (success) {
            success(data);
        }
    }];
    
}

@end
