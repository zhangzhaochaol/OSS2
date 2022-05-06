//
//  Yuan_NewFL_HttpModel.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN




@interface Yuan_NewFL_HttpModel : NSObject


/// 条件查询光链路
+ (void) Http_SelectLinkList:(NSDictionary *)param
                     success:(void(^)(id result))success;


/// 条件查询局向光纤
+ (void) Http_SelectRouteList:(NSDictionary *)param
                      success:(void(^)(id result))success;


/// 根据局向光纤Id 查询下属路由
+ (void) Http_SelectRouteFromId:(NSString *)routeId
                        success:(void(^)(id result))success;


/// 根据光路Id 查询下属路由
+ (void) Http_SelectLinkFromId:(NSString *)linkId
                       success:(void(^)(id result))success;

/// 光链路中 新增路由节点
+ (void) Http_LinkAddEpt:(NSDictionary *) dict
                 success:(void(^)(id result))success;




/// 根据光路内链路个数 初始化光链路
+ (void) Http_CreateLinesFromLinkId:(NSString *)linkId
                            success:(void(^)(id result))success;




/// 根据路由节点的Id查询所在光链路
/// @param routeId 节点id
/// @param routeTypeId 节点类型id
+ (void) Http_SearchLinksFromRouterId:(NSString *)routeId
                          routeTypeId:(NSString *)routeTypeId
                              success:(void(^)(id result))success;


/// 根据端子id 查询光路路由数据
+ (void) Http_SearchLinkRouteFromTerminalId:(NSString *) terminalId
                                    success:(void(^)(id result))success;



#pragma mark - 辅助接口 ---

/// 根据光缆段Id 查询光缆段详细信息数据
+ (void) Http_GetCableDataFromCableId:(NSString *) cableId
                              success:(void(^)(id result))success;




/// 清空 辅助接口
+ (void) Http_ClearLinkId:(NSString *)Id_A
                      IdB:(NSString *)Id_B
                  success:(void(^)(id result))success;




/// 根据端子纤芯数据 反查父设备数据  --- 端子查设备 , 纤芯查光缆段
+ (void) Http_GetFiberOrTerminal_SuperDataFromArray:(NSArray *) array
                                            success:(void(^)(id result))success;




/// 根据端子的Id , 查询当前的端子状态 是否已成端
+ (void) Http_SelectTerminalsStateFromIds:(NSArray *)terminalIds
                                  success:(void(^)(id result))success;


/// 验证端子或者纤芯 或者是局向光纤 是否已经有关系了
+ (void) Http2_CheckChooseTerminalOrFiberShip:(NSDictionary *) TF_Dict
                                     success:(void(^)(id result))success;


/// 根据光链路id 查询光链路详细信息
+ (void) Http2_GetLinkFromLinkId:(NSString *) linkId
                         success:(void(^)(id result))success;


#pragma mark - 二期 2021.10 ---

/// 哪些组合成新的局向光纤?
+ (void) Http2_ComboRouteFromComboArr:(NSArray *) datas
                              success:(void(^)(id result))success;


/// 光链路路由节点的替换
+ (void) Http2_ExchangeRouterPointInLinks:(NSDictionary *) exchangePostDict
                           success:(void(^)(id result))success;


/// 局向光纤路由节点的替换
+ (void) Http2_ExchangeRouterPointInRoutes:(NSDictionary *) exchangePostDict
                                   success:(void(^)(id result))success;


/// 光链路路由和局向光纤路由节点的删除
+ (void) Http2_DeleteRouterPoint:(NSDictionary *) deleteDict
                          isLink:(BOOL) isLink
                         success:(void(^)(id result))success;


/// 光链路路由节点的插入
+ (void) Http2_InsertInLinks:(NSDictionary *) insertDict
                 insertIndex:(NSInteger) insertIndex
                       links:(NSArray *) links
                     success:(void(^)(id result))success;



/// 局向光纤节点的插入
+ (void) Http2_InsertInRoutes:(NSDictionary *) insertDict
                  insertIndex:(NSInteger) insertIndex
                        links:(NSArray *) links
                      success:(void(^)(id result))success;

/// 根据设备id和类型 查询同设备的局向光纤
+ (void) Http2_SelectRoutesList:(NSDictionary *) dict
                        success:(void(^)(id result))success;



#pragma mark - 三期 2022.03 ---


/// 根据光链路 局向光纤id 查询对应父类的 经纬度信息 , 绘制在地图上
+ (void) Http3_SelectPointCoorsDict:(NSDictionary *) dict
                            success:(httpSuccessBlock)success;



/// 根据端子或者纤芯 , 查询所在的局向光纤
+ (void) Http3_SelectRouteFromTerFibDict:(NSDictionary *) dict
                                 success:(httpSuccessBlock)success;


/// 衰耗分解接口
+ (void) Http3_DecayPortDict:(NSDictionary *) dict
                     success:(httpSuccessBlock)success;

@end



NS_ASSUME_NONNULL_END
