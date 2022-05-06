//
//  Yuan_BlockLabelView.m
//  INCP&EManager
//
//  Created by 袁全 on 2020/7/29.
//  Copyright © 2020 智能运维. All rights reserved.
//

#import "Yuan_BlockLabelView.h"

@implementation Yuan_BlockLabelView

{
    UIView * _blockView;
    
    UILabel * _title;
    
    
    UIColor * _initColor;
    NSString * _initTitleTxt;
}

#pragma mark - 初始化构造方法

- (instancetype) initWithBlockColor:(UIColor *)color
                              title:(NSString *)title {
    
    if (self = [super init]) {
        
        _initColor = color;
        _initTitleTxt = title;
        
        [self UI_Config];
    }
    return self;
}




- (void) UI_Config {
    
    _blockView = [UIView viewWithColor:_initColor ?: UIColor.blackColor];
    _title = [UIView labelWithTitle:_initTitleTxt ?: @"" frame:CGRectNull];
    _title.numberOfLines = 0;//根据最大行数需求来设置
    _title.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self addSubviews:@[_blockView,_title]];
    [self layoutAllSubViews];
}



- (void) title:(NSString *)title  {
    
    
    _title.text = title;
    
}

- (void) blockColor:(UIColor *)color {
    
    _blockView.backgroundColor = color;
    
}


- (void) font:(float)font_fl {
    
    _title.font = Font_Yuan(font_fl);
    
}





#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    [_blockView autoConstrainAttribute:ALAttributeHorizontal toAttribute:ALAttributeHorizontal ofView:self withMultiplier:1.0];
    
    [_blockView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:Horizontal(0)];
    [_blockView autoSetDimension:ALDimensionHeight toSize:Vertical(15)];
    [_blockView autoSetDimension:ALDimensionWidth toSize:Horizontal(5)];
    
    
    [_title autoConstrainAttribute:ALAttributeHorizontal
                       toAttribute:ALAttributeHorizontal
                            ofView:_blockView
                    withMultiplier:1.0];
    
    [_title autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_blockView withOffset:Horizontal(3)];
    
    [_title autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(0)];
    
}
@end
