//
//  Yuan_OBD_Points_ConnectTipsVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , Yuan_OBD_PointTips_) {
    Yuan_OBD_PointTips_None,        //无关联方式
    Yuan_OBD_PointTips_Handle,      //手动关联
    Yuan_OBD_PointTips_Auto,        //自动关联
};


@interface Yuan_OBD_Points_ConnectTipsVC : Inc_BaseVC

/** 选择关联方式  block */
@property (nonatomic , copy) void (^pointTipsBlock) (Yuan_OBD_PointTips_ tipsEnum);

@end

NS_ASSUME_NONNULL_END
