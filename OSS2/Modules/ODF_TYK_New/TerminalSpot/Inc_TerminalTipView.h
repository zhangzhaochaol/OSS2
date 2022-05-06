//
//  Inc_TerminalTipView.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/7/8.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Inc_TerminalTipView : UIView

//按钮回调
@property (copy, nonatomic) void(^btnBlock)(UIButton * btn);

//开始倒计时
- (void)startTimer;
//停止
- (void)stopTimer;
@end



