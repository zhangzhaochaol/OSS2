//
//  Inc_BusCableFiberView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define BusCableSubFiberClickNotification @"BusCableSubFiberClickNotification"

typedef NS_ENUM(NSUInteger , Yuan_BusCableEnum_) {
    Yuan_BusCableEnum_Normal,           //普通
    Yuan_BusCableEnum_NewFL,            //新版 光纤光路 光链路 2021年3月
    Yuan_BusCableEnum_NewFL_Exchange,   // 新版 光纤光路 光链路 替换 2021年10月
};

@interface Inc_BusCableFiberView : UIView

/** 用来跳转 */
@property (nonatomic,strong) UIViewController *vc;

/** 纤芯 */
@property (nonatomic , assign) Yuan_BusCableEnum_ busCableEnum;



- (instancetype) initWithCableData:(NSDictionary *)cableDict;

/// 重置数据源
/// @param dataSource 网络请求结果
- (void) dataSource:(NSArray *) dataSource;


- (void) reloadData;


#pragma mark - 2021.6.18 新增 ---


/** 仅控制高亮 */
@property (nonatomic , assign) BOOL isControlFibers_HighLight;

/// 控制传入的端子 高亮或取消高亮
- (void) letFiber_Ids:(NSArray *) FiberIdsArr isHighLight:(BOOL)isHighLight;


@end

NS_ASSUME_NONNULL_END
