//
//  CusLabel.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/7/12.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "CusLabel.h"

@implementation CusLabel
@synthesize tagDic;
- (void)drawTextInRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, self.outLineWidth);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    CGContextSetTextDrawingMode(c, kCGTextStroke);
    self.textColor = self.outLinetextColor;
    [super drawTextInRect:rect];
    self.textColor = self.labelTextColor;
    CGContextSetTextDrawingMode(c, kCGTextFill);
    [super drawTextInRect:rect];
}
@end
