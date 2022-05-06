//
//  Inc_Push_MB.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/11/5.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

// *** 用于模板跳转

#import "TYKDeviceInfoMationViewController.h"
//#import "IWPPropertiesReader.h"



/// 新模板详情页
#import "Inc_NewMB_DetailVC.h"

/// 新模板列表页
#import "Inc_NewMB_ListVC.h"
#import "Inc_NewMB_VM.h"

NS_ASSUME_NONNULL_BEGIN

@interface Inc_Push_MB : NSObject


/// 通用模板界面跳转  -- 无数据模式
+ (void) PushOldMB_FromResLogicName:(NSString *)resLogicName
                                Gid:(NSString *)GID
                                 vc:(UIViewController *)vc; 



/// 通用模板界面跳转  -- 有数据模式
+ (TYKDeviceInfoMationViewController *) pushFrom:(UIViewController *)vc
                                    resLogicName:( NSString * _Nonnull )resLogicName
                                            dict:( NSDictionary * _Nonnull )dict
                                            type:(TYKDeviceListControlTypeRef)type;



//// 光缆段 特殊跳转
//+ (TYKDeviceInfoMationViewController *) push_Cable_From:(UIViewController *)vc
//                                                   dict:(NSDictionary * _Nonnull)dict
//                                                   type:(TYKDeviceListControlTypeRef)type;


// 跳转资源列表
+ (void) pushResourceTYKListFrom:(UIViewController *)vc
                        fileName:(NSString *)fileName
                        showName:(NSString *)showName;



/// 跳转通用列表 点击获取资源并返回
/// @param vc 从谁这跳
/// @param resLogicName resLogicName 必填
/// @param block 回调
+ (void) chooseResource_PushFrom:(UIViewController *)vc
                    resLogicName:(NSString * _Nonnull)resLogicName
                           Block:(void(^)(NSDictionary * dict))block;



#pragma mark - 新模板 ---

/// 新模板详情
+ (Inc_NewMB_DetailVC *) push_NewMB_Detail_RequestDict:(NSDictionary *) requestDict
                                                  Enum:(Yuan_NewMB_ModelEnum_) Enum
                                                    vc:(UIViewController *) vc;



/// 新模板详情列表
+ (void) push_NewMB_ListEnum:(Yuan_NewMB_ModelEnum_) Enum
                          vc:(UIViewController *) vc;



/// 新模板 根据id 查询详细信息
+ (void) NewMB_GetDetailDictFromGid:(NSString *) gid
                               Enum:(Yuan_NewMB_ModelEnum_) Enum
                            success:(void(^)(NSDictionary * dict)) success;


// 新模板 根据gid 直接查询详情 并且跳转详细信息页面
+ (void) NewMB_PushDetailsFromId:(NSString *) gid
                            Enum:(Yuan_NewMB_ModelEnum_) Enum
                              vc:(UIViewController *)vc;


// 新模板 根据gid 直接查询详情 并且跳转详细信息页面 并且有保存的回调
+ (void) NewMB_PushDetailsFromId:(NSString *) gid
                            Enum:(Yuan_NewMB_ModelEnum_) Enum
                              vc:(UIViewController *)vc
                       saveBlock:(void(^)(id result))saveBlock;


@end

NS_ASSUME_NONNULL_END
