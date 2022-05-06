//
//  Yuan_OBD_PointsConfigVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/15.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_OBD_PointsConfigVC : Inc_BaseVC


/// 构造方法
/// @param OBD_Id 分光器Id
/// @param deviceId 设备Id
/// @param device_MBDict 设备map
- (instancetype)initWith_OBD_Id:(NSString *)OBD_Id
                       deviceId:(NSString *)deviceId
                     deviceType:(NSString *)deviceType
                     deviceDict:(NSDictionary *)device_MBDict;

@end

NS_ASSUME_NONNULL_END
