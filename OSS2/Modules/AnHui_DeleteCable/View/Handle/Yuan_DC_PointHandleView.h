//
//  Yuan_DC_PointHandleView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/12.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Yuan_PointAnnotation.h"

NS_ASSUME_NONNULL_BEGIN


// 点击事件的回调枚举
typedef NS_ENUM(NSUInteger , DC_PointHandle_) {
    DC_PointHandle_GetRoute,        //获取路由
    DC_PointHandle_GetAnotherLines, //获取其他线路
    DC_PointHandle_DeleteCable,     //撤缆
    DC_PointHandle_Cancel,          //关闭
    DC_PointHandle_ConnectDevice,   //关联设备 
};

@interface Yuan_DC_PointHandleView : UIView


/** 我的source_Dict */
@property (nonatomic , copy , readonly) NSDictionary * myDict;


- (instancetype)initWithBtnHandlesBlock:(void(^)(DC_PointHandle_ handleType))handleBlock;



- (void) reloadHandleDict:(NSDictionary *)dict dcType:(DC_AnnoPointType_)dcType;


// 隐藏按钮
- (void) btnsHide;

@end

NS_ASSUME_NONNULL_END
