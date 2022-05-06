//
//  Yuan_ML_HttpModel.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/27.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_ML_HttpModel.h"



#define UpLoad @"resOptLog/addApply"                    //新增
#define SelectList @"resOptLog/selectResDelApply"       //列表
#define NoPass @"resOptLog/applyReject"                 //不通过
#define Agree @"resOptLog/applyAuthorized"              //通过

#define DeleteTrue @"pub/cascadeDelete"                 //彻底删除
#define CheckRegion @"resOptLog/findRelatedRes"         //验证所属维护区域
@implementation Yuan_ML_HttpModel


// 查询列表
+ (void) HTTP_MLD_Select:(NSDictionary *) dict
                 success:(void(^)(id result)) success {
    
    [[Http shareInstance] DavidJsonPostURL:[Yuan_ML_HttpModel URL:SelectList]
                                     Parma:dict
                                   success:^(id result) {
        
        if (success) {
            success(result);
        }
        
    }];
    
    
}


// 提交
+ (void) HTTP_MLD_UpLoadApply:(NSDictionary *) dict
                      success:(void(^)(id result)) success {
    
    [[Http shareInstance] DavidJsonPostURL:[Yuan_ML_HttpModel URL:UpLoad]
                                     Parma:dict
                                   success:^(id result) {
        
        if (success) {
            success(result);
        }
        
    }];
}


// 同意
+ (void) HTTP_MLD_AgreeApply:(NSDictionary *) dict
                     success:(void(^)(id result)) success {
    
    [[Http shareInstance] POST:[Yuan_ML_HttpModel URL:Agree]
                          dict:dict
                       succeed:^(id data) {
        
        NSNumber * code = data[@"code"];
        
        if (code.intValue == 200) {
            if (success) {
                success(data);
            }
        }
        
 
    }];
}


// 拒绝
+ (void) HTTP_MLD_NoPassApply:(NSDictionary *) dict
                      success:(void(^)(id result)) success {
    
    
    [[Http shareInstance] POST:[Yuan_ML_HttpModel URL:NoPass]
                          dict:dict
                       succeed:^(id data) {
        
        
        NSNumber * code = data[@"code"];
        
        if (code.intValue == 200) {
            if (success) {
                success(data);
            }
        }
    }];
}
   
// 删除
+ (void) HTTP_MLD_Delete:(NSDictionary *) dict
                 success:(void(^)(id result)) success {
    
    
    
    [[Http shareInstance] DavidJsonPostURL:[Yuan_ML_HttpModel URL:DeleteTrue]
                                     Parma:dict
                                   success:^(id result) {
        
        if (success) {
            success(result);
        }
        
    }];
    
    
    
}


/// 查询关联资源并验证管理区域
+ (void) HTTP_MLD_CheckRegion:(NSDictionary *) dict
                      success:(void(^)(id result)) success {
    
    [[Http shareInstance] DavidJsonPostURL:[Yuan_ML_HttpModel URL:@"resOptLog/findRelatedRes"]
                                     Parma:dict
                                   success:^(id result) {
        
        if (success) {
            success(result);
        }
        
    }];
}


+ (NSString *) URL:(NSString *) myURL {
    
    return [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,myURL];
    
}




@end
