//
//  UIView+Yuan_LayoutPacking.h
//  INCP&EManager
//
//  Created by 袁全 on 2020/7/30.
//  Copyright © 2020 智能运维. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Yuan_LayoutPacking)


typedef NS_ENUM(NSUInteger, DirectionLayout_) {
    DirectionLayout_MyTopToYourBottom ,
    DirectionLayout_MyLeftToYourRight
};


typedef NS_ENUM(NSUInteger , YuanViewToView_Layout_) {
    Top,
    Bottom,
    Left,
    Right,
};


#pragma mark -  方向对齐  ---


/// 水平对齐
- (NSLayoutConstraint *) YuanAttributeHorizontalToView:(UIView *)view;

- (NSLayoutConstraint *) YuanAttributeHorizontalToView:(UIView *)view
                                            multiplier:(float)multiplier;


/// 垂直对齐
- (NSLayoutConstraint *) YuanAttributeVerticalToView:(UIView *)view;

- (NSLayoutConstraint *) YuanAttributeVerticalToView:(UIView *)view
                                          multiplier:(float)multiplier;

/// 相对居中
- (void) YuanAttributeCenterToView:(UIView *)view;




// View To View
- (NSLayoutConstraint *) YuanMyEdge:(YuanViewToView_Layout_)myEdge
                         ToViewEdge:(YuanViewToView_Layout_)viewEdge
                             ToView:(UIView *)view
                              inset:(float)inset;


// 上下左右
- (NSLayoutConstraint *) YuanToSuper_Left:(float)inset;
- (NSLayoutConstraint *) YuanToSuper_Right:(float)inset;

- (NSLayoutConstraint *) YuanToSuper_Top:(float)inset;
- (NSLayoutConstraint *) YuanToSuper_Bottom:(float)inset;


// 设置内边距
- (NSArray *) Yuan_Edges:(UIEdgeInsets)insets;


// 长宽
- (NSLayoutConstraint *) Yuan_EdgeHeight:(float)height;
- (NSLayoutConstraint *) Yuan_EdgeWidth:(float)width;
- (NSArray *) Yuan_EdgeSize:(CGSize)size;




@end

NS_ASSUME_NONNULL_END
