//
//  YKLListView.h
//  YKLListViewDemo
//
//  Created by 擎杉 on 2017/1/17.
//  Copyright © 2017年 艾玩世纪互动娱乐. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kHideShowAnimateTime .3f



typedef NS_ENUM(NSUInteger, YKLListAnimationDirection) {
    YKLListAnimationDirectionLeft, // 隐藏到屏幕左侧
    YKLListAnimationDirectionRight, // 隐藏到屏幕右侧
    YKLListAnimationDirectionTop, // 隐藏到屏幕上方
    YKLListAnimationDirectionBottom, // 隐藏到屏幕下方
};

@interface YKLListView : UITableView

/**
 初始化一个ListView

 @param frame frame
 @param style 动画方向
 */
-(instancetype)initWithFrame:(CGRect)frame animateStyle:(YKLListAnimationDirection)style;


/**
 隐藏ListView，isNoAnimation：不使用动画？
 */
-(void)hideListViewNOAnimation:(BOOL)isNoAnimation;

/**
 显示ListView，isNoAnimation：不使用动画?
 */
-(void)showListViewNOAnimation:(BOOL)isNoAnimation;
@end
