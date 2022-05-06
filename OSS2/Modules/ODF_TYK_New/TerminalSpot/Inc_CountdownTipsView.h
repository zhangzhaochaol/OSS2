//
//  Inc_CountdownTipsView.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/2.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_CountdownTipsView : UIView

/// 提示
/// @param frame frame
/// @param title 提示title
/// @param msg 提示内容
/// @param time 倒计时时间

-(instancetype)initWithFrame:(CGRect)frame title:(NSString*)title message:(NSString *)msg time:(int)time;

//确定回调
@property (copy, nonatomic) void(^sureBlock)(void);

//取消回调
@property (copy, nonatomic) void(^cancelBlock)(void);

//高度
@property (copy, nonatomic) void(^heightBlock)(CGFloat height);

//开始倒计时
- (void)startTimer;
//停止
- (void)stopTimer;


@end

NS_ASSUME_NONNULL_END
