//
//  Inc_CableHeadView.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/14.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_CableHeadView : UIView

/** 模板dict */
@property (nonatomic , copy) NSDictionary * mb_Dict;

@property (nonatomic, copy) void (^heightBlok)(CGFloat height);

@end

NS_ASSUME_NONNULL_END
