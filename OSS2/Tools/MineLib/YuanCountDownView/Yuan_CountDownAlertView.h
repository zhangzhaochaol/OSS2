//
//  Yuan_CountDownAlertView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/11/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_CountDownAlertView : UIView

/** 倒计时结束 或者 手动点击回调  block */
@property (nonatomic , copy) void (^CountDownAlertBlock) (void);


/// 文字描述 文字详细信息弹框
- (instancetype)initWithSecond:(NSInteger) time
                   headerTitle:( NSString * _Nullable ) headerTitle
                     detailMsg:( NSString * _Nullable ) detailMsg;

@end

NS_ASSUME_NONNULL_END
