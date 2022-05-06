//
//  INCPrivacyManager.h
//  ChinaUnicom_Liaoning
//
//  Created by 王旭焜 on 2018/4/3.
//  Copyright © 2018年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, INCPrivacyManagerPrivacyType) {
    INCPrivacyManagerPrivacyTypeLocation_WhenInUse, //!< 定位权限 - 使用时
    INCPrivacyManagerPrivacyTypeLocation_Always,//!< 定位权限 - 后台
    INCPrivacyManagerPrivacyTypeCamera, //!< 相机权限
    INCPrivacyManagerPrivacyTypePhotoLibrary, //!< 相册
    INCPrivacyManagerPrivacyTypeNet, //!< 网络权限
    INCPrivacyManagerPrivacyTypeMicrophone, //!< 话筒权限
    INCPrivacyManagerPrivacyTypeNotification, //!< 推送权限
    INCPrivacyManagerPrivacyTypeCalendar, //!< 日历/行事历
    INCPrivacyManagerPrivacyTypeReminder, //!< 提醒事件
    INCPrivacyManagerPrivacyTypeContacts, //!< 联系人
};
typedef NS_ENUM(NSUInteger, INCPrivacyManagerPrivacyState) {
    
    INCPrivacyManagerPrivacyStateWhenInUse,
    INCPrivacyManagerPrivacyStateAlways,
    INCPrivacyManagerPrivacyStateAlow,
    INCPrivacyManagerPrivacyStateDenied,
    INCPrivacyManagerPrivacyStateNotDetermined,
};


@interface INCPrivacyManager : NSObject

/**
 获取单例
 */
+ (instancetype)privacyManager;

/**
 验证是否拥有某项权限

 @param type 权限类别
 @return 状态
 */
- (INCPrivacyManagerPrivacyState)isHavePrivacyForType:(INCPrivacyManagerPrivacyType)type;

/**
 请求某项权限

 @param type 权限类别
 */
- (void)requestPrivacyForType:(INCPrivacyManagerPrivacyType)type;

/**
 显示某项权限的提示框

 @param type 权限类别
 */
- (void)showDeniedHint:(INCPrivacyManagerPrivacyType)type;
@end
