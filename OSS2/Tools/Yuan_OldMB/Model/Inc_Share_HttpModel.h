//
//  Inc_Share_HttpModel.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/7/14.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_Share_HttpModel : NSObject


/// 查询是否有新分享推送的接口
+ (void) http_SelectShareNotis:(NSDictionary *) parma
                       success:(void(^)(id result)) success;


/// 查询分享列表
+ (void) http_SelectShareList:(NSDictionary *) parma
                      success:(void(^)(id result)) success;


/// 查询路由详情
+ (void) http_SelectRouterFromRoute:(NSString *) targetId
                            success:(void(^)(id result)) success;


/// 转发
+ (void) http_ForwardingFromParam:(NSDictionary *) parma
                          success:(void(^)(id result)) success;

/// 执行
+ (void) http_UpDataFromParam:(NSDictionary *) parma
                      success:(void(^)(id result)) success;
@end

NS_ASSUME_NONNULL_END
