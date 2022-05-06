//
//  Yuan_ODF_HttpModel.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/6/1.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


#define ODF_ImageCheckUnion @"unionAiApi/uploadPhoto"

@interface Yuan_ODF_HttpModel : NSObject



/// 请求列框信息
/// @param gid 传入的id的值
/// @param success 成功的回调
+ (void) ODF_HttpGetLimitDataWithID:(NSString *)gid
                           InitType:(NSString *)type
                       successBlock:(void(^)(id requestData))success;




/// @param equName 设备名称
/// @param equType 设备类型
/// @param equId 设备Id
/// @param position 位置
/// @param isFaceInverse 正反面
/// @param moduleRowQuantity 模块行
/// @param moduleColumnQuantity 模块列
/// @param moduleTubeColumn 模块端子数量
/// @param Rule_Dire 模块排列
/// @param success 回调

/// 初始化pie
/// @param dict 上传用的字典
+ (void) ODF_HttpInitDict:(NSDictionary *)dict
             successBlock:(void(^)(id requestData))success;



#pragma mark - 郑小英新的 初始化模块  ---
+ (void) ODF_HttpNewInitModuleWithDict:(NSDictionary *)dict
                               success:(httpSuccessBlock)success;




/// 删除端子信息
/// @param postDict parma
/// @param success 回调
+ (void) ODF_HttpDeleteDict:(NSDictionary *)postDict
               successBlock:(void(^)(id requestData))success;







/// 详情 端子盘
/// @param postDict parma dict
/// @param success 回调
+ (void)ODF_HttpDetail_Dict:(NSDictionary *)postDict
               successBlock:(void(^)(id requestData))success;




/// 长按 创建模块信息
/// @param postDict 参数
/// @param success 回调
+ (void)ODF_HttpLongPressInitModuleDict:(NSDictionary *)postDict
                           successBlock:(void(^)(id requestData))success;



#pragma mark - 2021年图片识别 ---

/// 图片识别接口 //
+ (void)ODF_HttpImageToUnion:(UIImage *)image
                successBlock:(void(^)(id requestData))success;



/// 批量修改 端子修改后的返回接口
+ (void)ODF_HttpImageToUnionBatchHold_TxtCoordinated:(NSArray *) txtCoordinated
                                             base64Img:(NSString *)img
                                                matrix:(NSArray *)matrix
                                        matrixModified:(NSArray *)matrixModified
                                          successBlock:(void(^)(id requestData))success;



///    --- 新端子识别 端子修改后的返回接口
+ (void)ODF_HttpImageToUnionImageCheck_TxtCoordinated:(NSArray *) txtCoordinated
                                            base64Img:(NSString *)img
                                               matrix:(NSArray *)matrix
                                       matrixModified:(NSArray *)matrixModified
                                         successBlock:(void(^)(id requestData))success;



// 修改端子状态
+ (void)ODF_HttpChangeTerminalState:(NSDictionary *)dict
                       successBlock:(void(^)(id requestData))success;




// 批量修改端子状态
+ (void) ODF_HttpChangeBatchHoldArray:(NSArray *)arr
                         successBlock:(void(^)(id requestData))success;



/// 2021-08-02 新增  郑小英接口 , 通过设备id 或 列框Id 查询下属端子盘端子
// 参数为 reqDb id type , 当没有type时默认的是根据列框id 查询 , 有type时 , 是根据设备查询
+ (void) http_NewPort_SelectTerminalsFromDict:(NSDictionary *)dict
                                 successBlock:(void(^)(id requestData))success;



/// 新接口 批量修改端子状态
+ (void) http_BatchSynchronizeTerminalStatus:(NSDictionary *) dict
                                successBlock:(void(^)(id requestData))success;



/// 2022-03-11, 替换通用查询分光器   目前端子盘查询分光器使用
+ (void) http_findOptResList:(NSDictionary *) dict successBlock:(void(^)(id requestData))success;



@end




NS_ASSUME_NONNULL_END
