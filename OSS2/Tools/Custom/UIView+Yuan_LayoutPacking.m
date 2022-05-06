//
//  UIView+Yuan_LayoutPacking.m
//  INCP&EManager
//
//  Created by 袁全 on 2020/7/30.
//  Copyright © 2020 智能运维. All rights reserved.
//

#import "UIView+Yuan_LayoutPacking.h"

@implementation UIView (Yuan_LayoutPacking)



#pragma mark -  方向对齐  ---


/// 水平对齐
- (NSLayoutConstraint *) YuanAttributeHorizontalToView:(UIView *)view {
    
    
  return   [self autoConstrainAttribute:ALAttributeHorizontal
                            toAttribute:ALAttributeHorizontal
                                 ofView:view
                         withMultiplier:1.0];
    
    
    
}


- (NSLayoutConstraint *) YuanAttributeHorizontalToView:(UIView *)view
                                            multiplier:(float)multiplier{
    
    
  return   [self autoConstrainAttribute:ALAttributeHorizontal
                            toAttribute:ALAttributeHorizontal
                                 ofView:view
                         withMultiplier:multiplier];
    
    
    
}


/// 竖直对齐
- (NSLayoutConstraint *) YuanAttributeVerticalToView:(UIView *)view {
    
    return [self autoConstrainAttribute:ALAttributeVertical
                            toAttribute:ALAttributeVertical
                                 ofView:view
                         withMultiplier:1.0];
}


/// 竖直对齐
- (NSLayoutConstraint *) YuanAttributeVerticalToView:(UIView *)view
                                          multiplier:(float)multiplier{
    
    return [self autoConstrainAttribute:ALAttributeVertical
                            toAttribute:ALAttributeVertical
                                 ofView:view
                         withMultiplier:multiplier];
}




/// 相对于 view 居中

- (void) YuanAttributeCenterToView:(UIView *)view {
    
    
    [self autoConstrainAttribute:ALAttributeVertical
                     toAttribute:ALAttributeVertical
                          ofView:view
                  withMultiplier:1.0];
    
    
    [self autoConstrainAttribute:ALAttributeHorizontal
                     toAttribute:ALAttributeHorizontal
                          ofView:view
                  withMultiplier:1.0];
    
}




#pragma mark - 上下左右 super ---


- (NSLayoutConstraint *) YuanToSuper_Left:(float)inset {
    
    return [self autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:inset];
}


- (NSLayoutConstraint *) YuanToSuper_Right:(float)inset {
    
    return [self autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:inset];
}

- (NSLayoutConstraint *) YuanToSuper_Top:(float)inset {
    
    return [self autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:inset];
}

- (NSLayoutConstraint *) YuanToSuper_Bottom:(float)inset {
    
    return [self autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:inset];
}


// 设置内边距
- (NSArray *) Yuan_Edges:(UIEdgeInsets)insets {
    
    return [self autoPinEdgesToSuperviewEdgesWithInsets:insets];
}

#pragma mark - view 与 view ---

- (NSLayoutConstraint *) YuanMyEdge:(YuanViewToView_Layout_)myEdge
                         ToViewEdge:(YuanViewToView_Layout_)viewEdge
                             ToView:(UIView *)view
                              inset:(float)inset {
    
    ALEdge my;
    ALEdge to;
    
    switch (myEdge) {
        case Top:
            my = ALEdgeTop;
            break;
        case Bottom:
            my = ALEdgeBottom;
            break;
        case Left:
            my = ALEdgeLeft;
            break;
        case Right:
            my = ALEdgeRight;
            break;
        default:
            break;
    }
    
    switch (viewEdge) {
        case Top:
            to = ALEdgeTop;
            break;
        case Bottom:
            to = ALEdgeBottom;
            break;
        case Left:
            to = ALEdgeLeft;
            break;
        case Right:
            to = ALEdgeRight;
            break;
        default:
            break;
    }
    
    
    
    return [self autoPinEdge:my toEdge:to ofView:view withOffset:inset];
}


#pragma mark - 设置长宽 ---
- (NSLayoutConstraint *) Yuan_EdgeHeight:(float)height {
    
    return [self autoSetDimension:ALDimensionHeight toSize:height];
}

- (NSLayoutConstraint *) Yuan_EdgeWidth:(float)width {
    
    return [self autoSetDimension:ALDimensionWidth toSize:width];
}

- (NSArray *) Yuan_EdgeSize:(CGSize)size {
    return [self autoSetDimensionsToSize:size];
}




@end
