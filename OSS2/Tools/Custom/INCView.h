//
//  INCView.h
//  INCP&EManager
//
//  Created by 王旭焜 on 2018/11/5.
//  Copyright © 2018 Tsingtao Increase S&T SY co., ltd. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface UIView (INCView) <CALayerDelegate>

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;

/**
 数据，可以存储任何数据备用
 */
@property (nonatomic, strong) id data;
@property (nonatomic, copy) NSString * Id;
@property (nonatomic, copy) NSString * key;
@property (nonatomic, copy) NSString * idKey;
@property (nonatomic, copy) NSString * nameKey;
@property (nonatomic, copy) NSString * valueKey;
@property (nonatomic, copy) NSString * unit;

@property (nonatomic, strong) UIFont * attributeFont;
@property (nonatomic, strong) UIColor * attributeColor;

@property (nonatomic, strong) NSArray * keyList;

@property (nonatomic, weak) UIView * savedView;
@property (nonatomic, strong) NSIndexPath * indexPathTemp;
@property (nonatomic, weak, readonly) UIViewController * viewController;
- (__kindof UIView *)viewWithId:(NSString *)Id;
- (void)addScaleAnimationOnView_forShow;
- (void)addScaleAnimationOnView_forHide;
- (void)brightColor:(UIColor *)color radius:(CGFloat)radius offset:(CGSize)offset opacity:(CGFloat)opacity;

- (void)setCornerRadius:(CGFloat)cornerRadius borderColor:(UIColor *)color borderWidth:(CGFloat)width;
- (void)addSubviews:(NSArray <__kindof UIView *> *)views;
- (void)jianBian:(NSArray <NSString *> *)colors;

@end
NS_ASSUME_NONNULL_BEGIN

NS_ASSUME_NONNULL_END
