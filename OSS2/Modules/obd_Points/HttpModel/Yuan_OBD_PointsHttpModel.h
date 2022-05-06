//
//  Yuan_OBD_PointsHttpModel.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_OBD_PointsHttpModel : NSObject


/// 输入端分光器端子和设备端子的绑定
+ (void) Http_Input_OBDPoint_Terminals_Connect:(NSDictionary *) datas
                                       success:(void(^)(id result)) succese;


/// 输入端分光器端子和设备端子的解绑
+ (void) Http_Input_OBDPoint_Terminals_DisConnect:(NSDictionary *) disConnectDict
                                          success:(void(^)(id result)) succese;




/// 输出端分光器端子和设备端子的绑定
+ (void) Http_OBDPoint_Terminals_Connect:(NSArray *) datas
                                 success:(void(^)(id result)) succese;



/// 输出端分光器端子和设备端子的解绑
+ (void) Http_OBDPoint_Terminals_DisConnect:(NSDictionary *) disConnectDict
                                    success:(void(^)(id result)) succese;



/// 根据设备端子的Id 查询分光器端子的关联关系  -- 通过分光器端子Id 查询
+ (void) Http_OBDPoint_Terminals_ShipSelect:(NSArray *) terminalIdsArr
                                    success:(void(^)(id result)) succese;


/// 根据设备端子的Id 查询分光器端子的关联关系  -- 通过设备端子Id 查询
+ (void) Http_OBDPoint_Terminals_ShipSelect_FromTerminals:(NSArray *) terminalIdsArr
                                                  success:(void(^)(id result)) succese;


// 根据分光器Id 初始化 分光器端子
+ (void) Http_OBD_Point_Init:(NSString *) OBD_resId
                     success:(void(^)(id result)) succese;

@end

NS_ASSUME_NONNULL_END
