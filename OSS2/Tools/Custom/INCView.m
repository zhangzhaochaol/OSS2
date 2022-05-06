//
//  INCView.m
//  INCP&EManager
//
//  Created by 王旭焜 on 2018/11/5.
//  Copyright © 2018 Tsingtao Increase S&T SY co., ltd. All rights reserved.
//

#import "INCView.h"

#import <objc/runtime.h>

static void * kPropertyName_View_IdName = @"kPropertyName_View_IdName";
static void * kPropertyName_View_ContentName = @"kPropertyName_View_ContentName";

@implementation UIView (INCView) 

-(void)setX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}
-(void)setY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}
-(void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}
-(void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}
-(CGFloat)x{
    return self.frame.origin.x;
}
-(CGFloat)y{
    return self.frame.origin.y;
}
-(CGFloat)width{
    return self.frame.size.width;
}
-(CGFloat)height{
    return self.frame.size.height;
}


- (void)addScaleAnimationOnView_forShow{
    //需要实现的帧动画，这里根据需求自定义
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"transform.scale";
    animation.values = @[@1.0,@1.3,@0.9,@1.15,@0.95,@1.02,@1.0];
    animation.duration = 1;
    animation.calculationMode = kCAAnimationCubic;
    [self.layer addAnimation:animation forKey:nil];
}

- (void)addScaleAnimationOnView_forHide{
    //需要实现的帧动画，这里根据需求自定义
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"transform.scale";
    animation.values = @[@1.0,@1.3,@0.9,@1.15,@0.6,@.3,@.0];
    animation.duration = 1;
    animation.calculationMode = kCAAnimationCubic;
    [self.layer addAnimation:animation forKey:nil];
}


-(void)setCornerRadius:(CGFloat)cornerRadius borderColor:(UIColor *)color borderWidth:(CGFloat)width{
    
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = cornerRadius != 0;
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
    
}
-(void)setData:(id)data{
    [self willChangeValueForKey:@"data"];
    objc_setAssociatedObject(self, @"data", data, OBJC_ASSOCIATION_RETAIN);
    [self didChangeValueForKey:@"data"];
}
-(id)data{
    id object = objc_getAssociatedObject(self, @"data");
    return object;
}
-(void)addSubviews:(NSArray<__kindof UIView *> *)views{
    
    BOOL isDebugMode = false;
    
#ifdef DEBUG
//        isDebugMode = true;
#endif
    
    [views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if ([view isKindOfClass:[UIView class]]) {
            
            if (isDebugMode) {
                view.backgroundColor = [UIColor anyColor];
            }
            
            
            [self addSubview:view];
        }
    }];
    
}

- (void)brightColor:(UIColor *)color radius:(CGFloat)radius offset:(CGSize)offset opacity:(CGFloat)opacity{
    
    if (color == [UIColor blackColor]) {
        color = [UIColor colorWithHexString:@"#bfbfbf"];
    }
    
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowRadius = radius;
    self.layer.shadowOffset = offset;
    self.layer.shadowOpacity = opacity;
}

@dynamic Id;
@dynamic key;

-(void)setIndexPathTemp:(NSIndexPath *)indexPathTemp{
    [self willChangeValueForKey:@"indexPathTemp"];
    objc_setAssociatedObject(self, @"indexPathTemp", indexPathTemp, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"indexPathTemp"];
}

-(NSIndexPath *)indexPathTemp{
    id object = objc_getAssociatedObject(self, @"indexPathTemp");
    return object;
}

- (NSString *)Id{
    id object = objc_getAssociatedObject(self, kPropertyName_View_IdName);
    return object;
}
- (void)setId:(NSString *)Id{
    [self willChangeValueForKey:(__bridge NSString * _Nonnull)(kPropertyName_View_IdName)];
    objc_setAssociatedObject(self, kPropertyName_View_IdName, Id, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:(__bridge NSString * _Nonnull)(kPropertyName_View_IdName)];
}
- (void)setKey:(NSString *)key{
    [self willChangeValueForKey:(__bridge NSString * _Nonnull)(kPropertyName_View_ContentName)];
    objc_setAssociatedObject(self, kPropertyName_View_ContentName, key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:(__bridge NSString * _Nonnull)(kPropertyName_View_ContentName)];
}
-(NSString *)key{
    id object = objc_getAssociatedObject(self, kPropertyName_View_ContentName);
    return object;
}

-(void)setUnit:(NSString *)unit{
    [self willChangeValueForKey:@"unit"];
    objc_setAssociatedObject(self, @"unit", unit, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"unit"];
}
-(NSString *)unit{
    id object = objc_getAssociatedObject(self, @"unit");
    return object;
}

- (void)setKeyList:(NSArray *)keyList{
    [self willChangeValueForKey:@"keyList"];
    objc_setAssociatedObject(self, @"keyList", keyList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"keyList"];
}
-(NSArray *)keyList{
    id object = objc_getAssociatedObject(self, @"keyList");
    return object;
}

-(void)setAttributeFont:(UIFont *)attributeFont{
    [self willChangeValueForKey:@"attributeFont"];
    objc_setAssociatedObject(self, @"attributeFont", attributeFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"attributeFont"];
}

-(void)setAttributeColor:(UIColor *)attributeColor{
    [self willChangeValueForKey:@"attributeColor"];
    objc_setAssociatedObject(self, @"attributeColor", attributeColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"attributeColor"];
}

-(UIFont *)attributeFont{
    id object = objc_getAssociatedObject(self, @"attributeFont");
    return object;
}

-(UIColor *)attributeColor{
    id object = objc_getAssociatedObject(self, @"attributeColor");
    return object;
}
-(void)setSavedView:(UIView *)savedView{
    [self willChangeValueForKey:@"savedView"];
    objc_setAssociatedObject(self, @"savedView", savedView, OBJC_ASSOCIATION_RETAIN);
    [self didChangeValueForKey:@"savedView"];
}

-(UIView *)savedView{
    id object = objc_getAssociatedObject(self, @"savedView");
    return object;
}

-(UIView *)viewWithId:(NSString *)Id{
    
    UIView * ret = nil;
    for (UIView * v in self.subviews) {
        if ([v.Id isEqualToString:Id]) {
            ret = v;
            break;
        }
    }
    
    return ret;
    
}

- (UIViewController *)viewController{
    
    for (UIView * next = [self superview]; next != nil; next = next.superview) {
        UIResponder * nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
    
}

-(void)jianBian:(NSArray<UIColor *> *)colors{
    
    NSMutableArray * arr = [NSMutableArray array];
    
    for (NSString * str in colors) {
        
        UIColor * color = [UIColor colorWithHexString:str];
        [arr addObject:(id)color.CGColor];
        
    }
    [self.superview layoutIfNeeded];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    
    NSLog(@"%@ - %@", @(self.layer.bounds), @(self.bounds));
    
    gradientLayer.frame = self.layer.bounds;  // 设置显示的frame
    gradientLayer.colors = arr;  // 设置渐变颜色
    
    gradientLayer.startPoint = CGPointMake(0.5, 0);   //
    gradientLayer.endPoint = CGPointMake(0.5, 1);     //
    gradientLayer.zPosition = -9999;
    [self.layer addSublayer:gradientLayer];
    
    
}

/*
 - (void)setKey:(NSString *)key{
 [self willChangeValueForKey:(__bridge NSString * _Nonnull)(kPropertyName_View_ContentName)];
 objc_setAssociatedObject(self, kPropertyName_View_ContentName, key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
 [self didChangeValueForKey:(__bridge NSString * _Nonnull)(kPropertyName_View_ContentName)];
 }
 -(NSString *)key{
 id object = objc_getAssociatedObject(self, kPropertyName_View_ContentName);
 return object;
 }
 */

-(void)setIdKey:(NSString *)idKey{
    [self willChangeValueForKey:(@"idKey")];
    objc_setAssociatedObject(self, @"idKey", idKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"idKey"];
}

-(NSString *)idKey{
    id object = objc_getAssociatedObject(self, @"idKey");
    return object;
}

-(void)setNameKey:(NSString *)nameKey{
    [self willChangeValueForKey:(@"nameKey")];
    objc_setAssociatedObject(self, @"nameKey", nameKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"nameKey"];
}
-(NSString *)nameKey{
    id object = objc_getAssociatedObject(self, @"nameKey");
    return object;
}
-(void)setValueKey:(NSString *)valueKey{
    [self willChangeValueForKey:(@"valueKey")];
    objc_setAssociatedObject(self, @"valueKey", valueKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"valueKey"];
}
-(NSString *)valueKey{
    id object = objc_getAssociatedObject(self, @"valueKey");
    return object;
}


//- (void)layoutSublayersOfLayer:(CALayer *)layer{
//    layer.frame = self.layer.bounds;
//}
@end
