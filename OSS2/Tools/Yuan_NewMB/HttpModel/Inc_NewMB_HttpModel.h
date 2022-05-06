//
//  Inc_NewMB_HttpModel.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Inc_NewMB_Model.h"


NS_ASSUME_NONNULL_BEGIN

@interface Inc_NewMB_HttpModel : NSObject

/// 新模板界面 查询资源
+ (void) HTTP_NewMB_SelectWithURL:(NSString *)url
                             Dict: (NSDictionary *) dict
                           success:(void(^)(id result)) success;


/// 新模板界面 根据Id 查询资源详细信息  入参是 id type; 或者 ids(数组) type
+ (void) HTTP_NewMB_SelectDetailsFromIdWithURL:(NSString *)url
                                          Dict: (NSDictionary *) dict
                                       success:(void(^)(id result)) success;



/// 新模板界面 新增资源
+ (void) HTTP_NewMB_AddWithURL:(NSString *)url
                          Dict: (NSDictionary *) dict
                        success:(void(^)(id result)) success;

/// 新模板界面 修改资源
+ (void) HTTP_NewMB_ModifiWithURL:(NSString *)url
                             Dict: (NSDictionary *) dict
                           success:(void(^)(id result)) success;

/// 新模板界面 删除资源
+ (void) HTTP_NewMB_DeleteWithURL:(NSString *)url
                             Dict: (NSDictionary *) dict
                           success:(void(^)(id result)) success;



#pragma mark - 辅助接口 --- --- --- --- --- --- --- --- ---


/// 通过OLT的Id 查询所属OLT的全部端口
+ (void) HTTP_NewMB_SelectOLTPort_OLTId:(NSString *) OLT_Id
                                success:(void(^)(id result)) success;



/// 通过reqDb 查询所属维护区域
+ (void) HTTP_NewMB_RegionListSuccess:(void(^)(id result)) success;


/// 根据省份获取 生产厂家列表
+ (void) HTTP_NewMB_ManufacturerList_Success:(void(^)(id result)) success;


/// 维护单位
+ (void) HTTP_NewMB_MaintainUnitList_Success:(void(^)(id result)) success;



/// 根据扫一扫 rfid , 获取资源类型和Id
+ (void) HTTP_NewMB_Rfid:(NSString *)rfid
                 Success:(void(^)(id result)) success;




/// 新模板 保存Rfid字段的单独接口
+ (void) HTTP_NewMB_SourceAdddigCodeDict:(NSDictionary *)dict
                                     Url:(NSString *) url
                                 Success:(void(^)(id result)) success ;



/// 新模板 查询分光器下属端子详情
+ (void) HTTP_NewMB_SelectDetailsFromOBD_PortWithURL:(NSString *)url
                                                Dict:(NSDictionary *) dict
                                             success:(void(^)(id result)) success;

@end

NS_ASSUME_NONNULL_END
