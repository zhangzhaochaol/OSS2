//
//  CusButton.m
//  OSS2.0-ios-v1
//
//  Created by 孟诗萌 on 16/4/5.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "CusButton.h"

@implementation CusButton
@synthesize tagDic;
@synthesize value;
//初始化方法
- (id)initWithFrame:(CGRect)frame {
    if ( self = [super initWithFrame: frame])
    {
        [self addTarget:self action:@selector(button1BackGroundHighlighted:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(button1BackGroundNormal:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(button1BackGroundNormal:) forControlEvents:UIControlEventTouchDragOutside];
        [self addTarget:self action:@selector(button1BackGroundHighlighted:) forControlEvents:UIControlEventTouchDragInside];
        
        [self cornerRadius:3 borderWidth:0 borderColor:UIColor.whiteColor];
        
    }
    return self;
}

//  button1普通状态下的背景色
- (void)button1BackGroundNormal:(UIButton *)sender
{
    [UIView animateWithDuration:.5f animations:^{
        sender.backgroundColor = [UIColor mainColor];
    }];
}

//  button1高亮状态下的背景色
- (void)button1BackGroundHighlighted:(UIButton *)sender
{
//    sender.backgroundColor = [UIColor colorWithRed:165/255.0 green:0.0 blue:0.0 alpha:0.6];
    sender.backgroundColor = [self.backgroundColor setAlpha:.7];
}

@end
