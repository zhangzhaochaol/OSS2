//
//  Inc_BusAllColumnView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/17.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

//端子
#import "Inc_BusDeviceView.h"
#import "Inc_BusScrollItem.h"
#import "Inc_Push_MB.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , BusAllColumnType_) {
    BusAllColumnType_ODF,
    BusAllColumnType_OCC,
    BusAllColumnType_ODB,
    BusAllColumnType_OBD

};


@interface Inc_BusAllColumnView : UIView


/**
    根据设备Id  和 设备类型 请求全部端子信息
 */
- (instancetype)initWithFrame:(CGRect)frame
                       isPush:(BOOL)isPush
                     deviceId:(NSString *)deviceId
                      busType:(BusAllColumnType_ )busType
               busDevice_Enum:(Yuan_BusDeviceEnum_)busDevice_Enum
                 busHttp_Enum:(Yuan_BusHttpPortEnum_)busHttp_Enum
                           vc:(UIViewController*)vc;



/**
    根据端子盘数据 请求 全部端子信息
 */
- (instancetype)initWithFrame:(CGRect)frame
                       isPush:(BOOL)isPush
            requestDataSource:(NSArray *)requestDataSource
               busDevice_Enum:(Yuan_BusDeviceEnum_)busDevice_Enum
                 busHttp_Enum:(Yuan_BusHttpPortEnum_)busHttp_Enum
                           vc:(UIViewController*)vc;





/** 所有端子盘加载成功后回调  block */
@property (nonatomic , copy) void (^httpSuccessBlock) (void);

//显示正反面  yes 正面  no反面
@property (nonatomic) BOOL isShowJust;

//item的点击事件 返回 全部的按钮和当前点击的按钮
@property (nonatomic , copy) void (^yuan_BusDeviceSelectItemBlock) (NSArray <Inc_BusScrollItem *> * btnsArr,Inc_BusScrollItem *item,Inc_BusDeviceView *busView);



//获取反面 DeviceView 数组
-(NSArray *)getDeviceViewBackArray;
//获取正面 DeviceView 数组
-(NSArray *)getDeviceViewJustArray;



/// 根据模块Id 去重新请求对应的模块数据
- (void) reloadAllDatas;

@end

NS_ASSUME_NONNULL_END
