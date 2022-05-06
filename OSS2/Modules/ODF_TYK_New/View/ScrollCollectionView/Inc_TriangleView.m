//
//  Inc_TriangleView.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/8.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_TriangleView.h"

@interface Inc_TriangleView ()

@property (strong, nonatomic) UIColor *color;


@end

@implementation Inc_TriangleView

- (instancetype)initWithColor:(UIColor *)color{
    if ([super init]) {
        _color = color;
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
}

- (void)drawRect:(CGRect)rect
{
    
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);//标记
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context,width, 0);
    CGContextAddLineToPoint(context,0, height);
    CGContextClosePath(context);//路径结束标志，不写默认封闭
    
    [_color setFill]; //设置填充色
    [_color setStroke];//边框也设置为_color，否则为默认的黑色
    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径path
    
    
}

@end
