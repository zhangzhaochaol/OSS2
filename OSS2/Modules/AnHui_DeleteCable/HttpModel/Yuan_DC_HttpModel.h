//
//  Yuan_DC_HttpModel.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2021/1/11.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


// 获取起始和终止设备
#define DC_GetStartEndDevicePort @"res/selectResByTypeAndIds"


// 获取路由资源
#define DC_GetCableRoutePort @"res/searchLineAndPointNoHole"

// 根据点资源查询所属线资源的下属段资源 (主)
#define DC_GetBelongResources @"res/findSectResOfLineByPointRes"

// 根据资源查询关联段资源  (副)
#define DC_GetRelateResource @"res/findSectAndPointNoHoleByRes"

// 自动穿缆
#define DC_AddRoutePort_Auto @"lineApi/autoUnHangingCable"

// 手动穿缆 -- 管孔时使用
#define DC_AddRoutePort_Hands @"lineApi/hangingCable"

// 撤缆
#define DC_DeleteRoutePort @"lineApi/unHangingCable"

// 根据管道段ID 获取下属管孔信息
#define DC_GetFatherTubePort @"lineRes/findPipeHoleByPipeSectId"

// 获取1000米范围内资源
#define DC_GetCircleSubPort @"res/searchResByScopePage"




@interface Yuan_DC_HttpModel : NSObject

// 获取起始终止设备
+ (void) http_GetStartEndDevice:(NSString *) cableId
                        success:(void(^)(id result))success;


// 获取光缆段下属路由
+ (void) http_GetCableRoute:(NSString *) cableId
                    success:(void(^)(id result))success;


// 获取半径范围内的下属资源  直传经纬度和半径
+ (void) http_GetCircleRadiusSubResMapCenterCoor:(CLLocationCoordinate2D) coor
                                         success:(void(^)(id result))success;




// 根据点资源查询所属线资源的下属段资源   点击获取线路按钮 (主)
+ (void) http_GetBelongResourceFromDict:(NSDictionary *) param
                                success:(void(^)(id result))success;



// 根据资源查询关联段资源      点击关联资源按钮 (副)
+ (void) http_GetReleatResourceFromDict:(NSDictionary *) param
                                success:(void(^)(id result))success;




// 撤缆接口
+ (void) http_DeleteCableFromArray:(NSArray *) deleteIdsArr
                          cableId :(NSString *)belongCableId
                           success:(void(^)(id result))success;




// 自动穿缆
+ (void) http_putUpCableAuto:(NSDictionary *) param
                     success:(void(^)(id result))success;





#pragma mark - 管孔穿缆相关 ---

// 手动穿缆 , 仅在手动 选管孔时使用
+ (void) http_putUpCableHands_FromArray:(NSArray *) param
                                success:(void(^)(id result))success;




// 根据管道段Id 获取下属管孔信息
+ (void) http_GetFatherTubeFromId:(NSString *) Id
                          success:(void(^)(id result))success;


@end

NS_ASSUME_NONNULL_END
