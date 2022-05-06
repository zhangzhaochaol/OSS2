//
//  Yuan_FL_HttpModel.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/12/1.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define FL_OpticalFiberPort @"optRes/searchOptLogicPairAndRoutesByNodeId"
#define FL_OpticalLinkPort @"optRes/searchOptRoadAndOPtPairLinkAndOptPairRouterByEptId"



@interface Yuan_FL_HttpModel : NSObject

// 获取局向光纤资源
+ (void) HTTP_FL_GetOpticalFiber:(NSDictionary *)dict
                         success:(void(^)(id result))success;



// 获取光纤链路资源
+ (void) HTTP_FL_GetOpticalLink:(NSDictionary *)dict
                        success:(void(^)(id result))success;


// 根据Gid 和 ResLogicName 获取资源数据
+ (void) HTTP_FL_GetResWithDict:(NSDictionary *)dict
                        success:(void(^)(id result))success;

@end

NS_ASSUME_NONNULL_END
