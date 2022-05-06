//
//  Yuan_OBD_PointVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/15.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_OBD_PointVC : Inc_BaseVC

// 分光器Id 初始化下属端子
- (instancetype)initWithSuperResId:(NSString *) superResId;
@end

NS_ASSUME_NONNULL_END
