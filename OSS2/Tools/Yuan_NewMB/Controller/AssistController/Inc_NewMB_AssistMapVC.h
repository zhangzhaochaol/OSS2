//
//  Inc_NewMB_AssistMapVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/6/11.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Inc_NewMB_AssistMapVC : Inc_BaseVC


/** 获取经纬度  block */
@property (nonatomic , copy) void (^Type4_GetLatLonBlock) (double lat ,double lon);

@end


NS_ASSUME_NONNULL_END
