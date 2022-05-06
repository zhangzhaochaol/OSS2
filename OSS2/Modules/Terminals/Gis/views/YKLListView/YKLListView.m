//
//  YKLListView.m
//  YKLListViewDemo
//
//  Created by 擎杉 on 2017/1/17.
//  Copyright © 2017年 艾玩世纪互动娱乐. All rights reserved.
//

#import "YKLListView.h"

@interface YKLListView ()
@property (nonatomic, assign) YKLListAnimationDirection animateStyle;
@property (nonatomic, assign) CGRect defaultFrame;

@end

@implementation YKLListView
-(instancetype)initWithFrame:(CGRect)frame animateStyle:(YKLListAnimationDirection)style{
    
    if (self = [super initWithFrame:frame style:UITableViewStyleGrouped]) {
        
        _animateStyle = style;
        
        
        
    }
    
    return self;
}

- (void)hideListViewNOAnimation:(BOOL)isNoAnimation{
    
    if (_animateStyle == YKLListAnimationDirectionTop) {
        
        [self hideIntoTopAnimate:!isNoAnimation];
        
    }else if (_animateStyle == YKLListAnimationDirectionLeft){
        
        [self hideIntoLeftAnimate:!isNoAnimation];
        
    }else if (_animateStyle == YKLListAnimationDirectionRight){
        [self hideIntoRightAnimate:!isNoAnimation];
    }else{
        [self hideIntoBottomAnimate:!isNoAnimation];
    }
    
}

- (void)showListViewNOAnimation:(BOOL)isNoAnimation{
    if (_animateStyle == YKLListAnimationDirectionTop) {
        [self showFormTopAnimate:!isNoAnimation];
    }else if (_animateStyle == YKLListAnimationDirectionLeft){
        [self showFormLeftAnimate:!isNoAnimation];
    }else if (_animateStyle == YKLListAnimationDirectionRight){
        [self showFormRightAnimate:!isNoAnimation];
    }else{
        [self showFormBottomAnimate:!isNoAnimation];
    }
}

- (void)hideIntoLeftAnimate:(BOOL)animate{
    
    CGRect frame = self.frame;
    frame.origin.x = 0 - frame.size.width;
    
    if (animate) {
        [UIView animateWithDuration:kHideShowAnimateTime animations:^{
            self.frame = frame;
            self.alpha = 0.f;
        }];
    }else{
        self.alpha = 0.f;
        self.frame = frame;
    }
    
}
- (void)hideIntoRightAnimate:(BOOL)animate{
    CGRect frame = self.frame;
    frame.origin.x = self.superview.frame.size.width;
    
    if (animate) {
        [UIView animateWithDuration:kHideShowAnimateTime animations:^{
            self.frame = frame;
            self.alpha = 0.f;
        }];
    }else{
        self.alpha = 0.f;
        self.frame = frame;
    }
}
- (void)hideIntoTopAnimate:(BOOL)animate{
    
    CGRect frame = self.frame;
    frame.origin.y = 0 - frame.size.height;
    
    if (animate) {
        [UIView animateWithDuration:kHideShowAnimateTime animations:^{
            self.frame = frame;
            self.alpha = 0.f;
        }];
    }else{
        self.alpha = 0.f;
        self.frame = frame;
    }
    
}
- (void)hideIntoBottomAnimate:(BOOL)animate{
    CGRect frame = self.frame;
    frame.origin.y = self.superview.frame.size.height;
    
    if (animate) {
        [UIView animateWithDuration:kHideShowAnimateTime animations:^{
            self.frame = frame;
            self.alpha = 0.f;
        }];
    }else{
        self.alpha = 0.f;
        self.frame = frame;
    }
}


- (void)showFormLeftAnimate:(BOOL)animate{
    CGRect frame = self.frame;
    
    frame.origin.x = 0.f;
    
    if (animate) {
        [UIView animateWithDuration:kHideShowAnimateTime animations:^{
            self.frame = frame;
            self.alpha = 1.f;
        }];
    }else{
        self.alpha = 0.f;
        self.frame = frame;
    }
    
    
}
- (void)showFormRightAnimate:(BOOL)animate{
    CGRect frame = self.frame;
    
    frame.origin.x = self.superview.frame.size.width - self.frame.size.width;
    
    if (animate) {
        [UIView animateWithDuration:kHideShowAnimateTime animations:^{
            self.frame = frame;
            self.alpha = 1.f;
        }];
    }else{
        self.alpha = 0.f;
        self.frame = frame;
    }
    
}
- (void)showFormTopAnimate:(BOOL)animate{
    
    CGRect frame = self.frame;
    
    frame.origin.y = 0;
    
    if (animate) {
        [UIView animateWithDuration:kHideShowAnimateTime animations:^{
            self.frame = frame;
            self.alpha = 1.f;
        }];
    }else{
        self.frame = frame;
    }
    
}
- (void)showFormBottomAnimate:(BOOL)animate{
    CGRect frame = self.frame;
    
    frame.origin.y = self.superview.frame.size.height - self.frame.size.height;
    
    if (animate) {
        [UIView animateWithDuration:kHideShowAnimateTime animations:^{
            self.frame = frame;
            self.alpha = 1.f;
        }];
    }else{
        self.frame = frame;
    }
}

-(void)setEditing:(BOOL)editing{
    if (editing) {
        _defaultFrame = self.frame;
        
        CGRect frame = self.frame;
        
        frame.origin.x = self.superview.frame.size.width / 5.f;
        frame.size.width = self.superview.frame.size.width - self.superview.frame.size.width / 5.f;
        
        [UIView animateWithDuration:kHideShowAnimateTime animations:^{
            self.frame = frame;
        }];
        
    }else{
        [UIView animateWithDuration:kHideShowAnimateTime animations:^{
            self.frame = _defaultFrame;
        }];
    }
    
    
    UIView * headerView = self.tableHeaderView;
    
    if (headerView) {
        
        CGRect frame = headerView.frame;
        frame.size.width = self.frame.size.width;
        [UIView animateWithDuration:kHideShowAnimateTime animations:^{
            headerView.frame = frame;
        }];
        
        
        NSInteger index = 0;
        
        for (UIView * subView in headerView.subviews) {
            
            CGRect sFrame = subView.frame;
            sFrame.size.width = headerView.frame.size.width / (CGFloat)headerView.subviews.count;
            
            if (index > 0) {
                
                //                UIView * lastView = headerView.subviews[index];
                
                sFrame.origin.x = sFrame.size.width * index;
                
                
            }
            
            [UIView animateWithDuration:kHideShowAnimateTime animations:^{
                subView.frame = sFrame;
            }];
            
            index++;
            
        }
        
        
    }
    
    
    
    [super setEditing:editing];
}


@end
