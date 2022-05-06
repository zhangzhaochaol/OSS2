//
//  Yuan_ML_HttpModel.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/27.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_ML_HttpModel : NSObject

// 查询列表
+ (void) HTTP_MLD_Select:(NSDictionary *) dict
                success:(void(^)(id result)) success;


// 提交
+ (void) HTTP_MLD_UpLoadApply:(NSDictionary *) dict
                      success:(void(^)(id result)) success;


// 同意
+ (void) HTTP_MLD_AgreeApply:(NSDictionary *) dict
                     success:(void(^)(id result)) success;


// 拒绝
+ (void) HTTP_MLD_NoPassApply:(NSDictionary *) dict
                      success:(void(^)(id result)) success;

// 删除
+ (void) HTTP_MLD_Delete:(NSDictionary *) dict
                 success:(void(^)(id result)) success;

/// 查询关联资源并验证管理区域
+ (void) HTTP_MLD_CheckRegion:(NSDictionary *) dict
                      success:(void(^)(id result)) success;

@end

NS_ASSUME_NONNULL_END
