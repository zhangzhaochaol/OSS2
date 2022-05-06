//
//  AMapNaviManagerConfig.h
//  AMapNaviManagerConfig
//
//  Created by yuanmenglong on 2021/8/25.
//  Copyright © 2021 Amap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapFoundationKit/AMapServices.h>
#import "AMapNaviCommonObj.h"
NS_ASSUME_NONNULL_BEGIN

@interface AMapNaviManagerConfig : NSObject
/**
 * @brief AMapNaviManagerConfig单例. since 8.0.1
 * @return AMapNaviManagerConfig实例
 */
+ (instancetype)sharedConfig;

/**
 * @brief 获取当前语音播报时控制音乐音量模式
 * @return AMapNaviControlMusicVolumeMode 当前播报时控制音乐音量模式
 */
- (AMapNaviControlMusicVolumeMode)getControlMusicVolumeMode;
/**
 * @brief 设置当前语音播报时控制音乐音量模式,默认为压低音乐模式,AMapNaviControlMusicVolumeModeDepress 注意:这里设置的值会存储到本地,下次app启动的时候会读取这个缓存值. since 8.0.1
 * @return void 无返回值
 */
- (void)setControlMusicVolumeMode:(AMapNaviControlMusicVolumeMode)mode;

/**
 * @brief 设置通话时是否收听语音播报,默认为不收听语音播报, 注意:这里设置的值会存储到本地,下次app启动的时候会读取这个缓存值. since 8.0.1
 * @return void 无返回值
 */
- (void)setListenToVoiceDuringCall:(BOOL)listenToVoiceDuringCallEnable;

/**
 * @brief 获取通话时是否收听语音播报
 * @return BOOL 获取通话时是否收听语音播报
 */
- (BOOL)isListenToVoiceDuringCall;

#pragma mark - Privacy 隐私合规
/**
 * @brief 更新App是否显示隐私弹窗的状态，隐私弹窗是否包含高德SDK隐私协议内容的状态，注意：必须在导航任何一个manager实例化之前调用. since 8.1.0
 * @param showStatus 隐私弹窗状态
 * @param containStatus 包含高德SDK隐私协议状态
 */
- (void)updatePrivacyShow:(AMapPrivacyShowStatus)showStatus privacyInfo:(AMapPrivacyInfoStatus)containStatus;

/**
 * @brief 更新用户授权高德SDK隐私协议状态，注意：必须在导航任何一个manager实例化之前调用. since 8.1.0
 * @param agreeStatus 用户授权高德SDK隐私协议状态
 */
- (void)updatePrivacyAgree:(AMapPrivacyAgreeStatus)agreeStatus;

@end

#pragma mark - Private

@interface AMapNaviManagerConfig (Private)

/**
 * @brief 设置途径点私有实例接口,外部禁止调用. since 7.9.0
 */
- (void)setViaPointEtaDisplayEnable:(BOOL )isEnable;
@end


NS_ASSUME_NONNULL_END
