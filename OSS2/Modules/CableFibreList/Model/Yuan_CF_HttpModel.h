//
//  Yuan_CF_HttpModel.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/21.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 重新初始化纤芯
static NSString * reInitFibers = @"lineApi/initPairList";


static NSString * selectOptPairB = @"optRes/selectOptPairByOptSectId";


static NSString * _batchDeleteReleationShips = @"lineApi/batchRemoveConjunction";

@interface Yuan_CF_HttpModel : NSObject



/// 光缆段纤芯列表的请求
/// @param cableId 光缆段ID
/// @param success 成功的回调
+ (void) Http_CableFilberListRequestWithCableId:(NSString *)cableId
                                        Success:(void(^)(NSArray * data))success;





/**
    cableSeg_Id 所属光缆段ID
    cableSeg 所属光缆段名称
    capacity 纤芯总数
*/

/// 初始化纤芯的请求
/// @param parma 参数
/// @param success 回调
+ (void) HttpFiberWithDict:(NSMutableDictionary *)parma
                   success:(void(^)(NSArray * data))success;










/// 通过光缆接头的Id 去查询关联的光缆段
/// @param startType 光缆段类型
/// @param startId 接头Id

+ (void) HttpCableStart_Type:(NSString *) startType
                    Start_Id:(NSString *) startId
                     success:(void(^)(NSArray * data))success;



#pragma mark -  保存纤芯配置接口  ---



/// 支持一次多发
/// @param saveMsgArray 存放每个map的数组
/// @param success 回调
+ (void) HttpCableFiberSaveSuccess:(void(^)(NSArray * data))success;



#pragma mark -  新增 撤销单独配置  ---

/// 撤销起始设备
+ (void) HttpCableFiberDelete_StartDeviceWithDict:(NSDictionary *)WDW_Dict
                                          Success:(void(^)(void))success;


/// 撤销终止设备
+ (void) HttpCableFiberDelete_EndDeviceWithDict:(NSDictionary *)WDW_Dict
                                        Success:(void(^)(void))success;



/// 新增 查看成端端子的关联关系
+ (void) HttpSelectFiberReleationShipWithTermIds:(NSString *)IDs
                                         Success:(void(^)(NSArray * data))success;






#pragma mark - 2021-08-02 ---

/// 重新初始化纤芯
+ (void) HttpReInit_Fibers:(NSDictionary *) dict
                   Success:(void(^)(id result))success;




#pragma mark - 2022-02-14 ---

/// 批量对纤芯删除 成端熔接关系
+ (void) HttpBatchDeleteReleationShips:(NSArray *) conjunctionList
                               success:(httpSuccessBlock)success;



@end

NS_ASSUME_NONNULL_END
