//
//  Inc_TE_ChooseTopView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , TE_ChooseTop_) {
    TE_ChooseTop_FullScreen,        //全屏
    TE_ChooseTop_HalfScreen,        //大半屏幕
};

@interface Inc_TE_ChooseTopView : UIView

- (instancetype)initWithEnum:(TE_ChooseTop_)Enum;

- (void) reloadWithDict:(NSDictionary *) dict ;

- (void) clear;

/** 当前是A端子还是B端子 , A 端子时 True , B false */
@property (nonatomic , assign) BOOL nowState_A_Or_B;


@end

NS_ASSUME_NONNULL_END
