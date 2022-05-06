//
//  Inc_NewFL_HttpModel1.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/7/5.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

// zzc   2021-6-15  端子、纤芯、局向光纤业务状态变更
// 端子、纤芯、局向光纤业务状态变更
#define NewFL_UpdateOprState @"eqpApi/updateOprState"

// 确认端子、纤芯、局向光纤业务状态变更
#define NewFL_ConfirmUpdateOprState @"eqpApi/confirmUpdateOprState"

// 根据设备ID查询查询所属端子信息
#define NewFL_SelectTermsByEqpId @"optRes/selectTermsByEqpId"

//根据光缆段ID或者设备ID查询关联的光路
#define NewFL_SelectRoadInfoByEqpId @"optRes/selectRoadInfoByEqpId"

//根据端子ID或者纤芯ID查询光路信息
#define NewFL_SelectRoadInfoByTermPairId @"optRes/selectRoadInfoByTermPairId"

//根据端子ids集合查看是否有光电路关系
#define NewFL_SelectRoadByTermIds @"optRes/selectRoadByTermIds"

//通过端子id查询承载业务
#define NewFL_GetRouterAndCircuitInfo @"lineRes/getRouterAndCircuitInfo"



//根据设备ID查询光缆段接口
#define NewFL_GetOpeSectAndPortIds @"res/getOpeSectAndPortIdsByEqpId"

//根据设备ID查询承载业务接口
#define NewFL_GetCircuitAndPortIds @"res/getCircuitAndPortIdsByEqpId"

//根据设备ID查询端子信息
#define NewFL_GetTermsByEqpId @"res/getPortsByEqpId"

@interface Inc_NewFL_HttpModel1 : NSObject


/// 端子、纤芯、局向光纤业务状态变更
+ (void) Http_UpdateOprState:(NSDictionary *)param
                      success:(void(^)(id result))success;



/// 确认端子、纤芯、局向光纤业务状态变更
+ (void) Http_ConfirmUpdateOprState:(NSDictionary *)param
                      success:(void(^)(id result))success;


/// 暂时无用  郑
/// 根据设备ID查询查询所属端子信息
+ (void) Http_SelectTermsByEqpId:(NSDictionary *)param
                      success:(void(^)(id result))success;



/// 根据光缆段ID或者设备ID查询关联的光路
+ (void) Http_SelectRoadInfoByEqpId:(NSDictionary *)param
                      success:(void(^)(id result))success;


/// 根据光缆段ID或者设备ID查询关联的光路
+ (void) Http_SelectRoadInfoByTermPairId:(NSDictionary *)param
                      success:(void(^)(id result))success;



/// 根据端子ids集合查看是否有光电路关系
+ (void) Http_SelectRoadByTermIds:(NSArray *)paramArr
                      success:(void(^)(id result))success;



///通过端子id查询承载业务
+ (void) Http_GetRouterAndCircuitInfo:(NSDictionary *)param
                      success:(void(^)(id result))success;



//根据设备ID查询光缆段接口
+ (void)Http_GetOpeSectAndPort:(NSDictionary *)param
                       success:(void(^)(id result))success;


//根据设备ID查询承载业务接口
+ (void)Http_GetCircuitAndPort:(NSDictionary *)param
                       success:(void(^)(id result))success;


//根据设备ID查询端子信息
+ (void)Http_GetTermSData:(NSDictionary *)param
                       success:(void(^)(id result))success;



@end



