//
//  Yuan_NewFL2_AlertWindow.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/10/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , AlertWindow_) {
    AlertWindow_TF,
    AlertWindow_Route,
    AlertWindow_Link,
};

typedef NS_ENUM(NSUInteger , AlertChooseType_) {
    AlertChooseType_Cancel,                 //取消
    AlertChooseType_Look,                   //查看所在光路/局向光纤
    AlertChooseType_ConstraintExchange,     //强制交换
};


@interface Yuan_NewFL2_AlertWindow : UIView

- (void) reloadWithEnum:(AlertWindow_) Enum;

/** 点击按钮的回调  block */
@property (nonatomic , copy) void (^AlertGoBlock) (AlertChooseType_ Enum);

@end

NS_ASSUME_NONNULL_END
