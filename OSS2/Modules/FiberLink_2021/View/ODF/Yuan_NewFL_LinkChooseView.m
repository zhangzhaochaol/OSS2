//
//  Yuan_NewFL_LinkChooseView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL_LinkChooseView.h"

@implementation Yuan_NewFL_LinkChooseView
{
    UILabel * _lineLab;
    
    UILabel * _detailAddress;
}

#pragma mark - 初始化构造方法

- (instancetype)initWithType:(LinkChooseType_) type {
    
    if (self = [super init]) {
        
        NSString * title;
        UIColor * backColor;
        if (type == LinkChooseType_First) {
            title = @"链路1";
            backColor = UIColor.greenColor;
        }
        else {
            title = @"链路2";
            backColor = UIColor.mainColor;
        }
        
        _lineLab = [UIView labelWithTitle:title frame:CGRectNull];
        _lineLab.textAlignment = NSTextAlignmentCenter;
        
        _detailAddress = [UIView labelWithTitle:@" " frame:CGRectNull];
        _detailAddress.textAlignment = NSTextAlignmentCenter;
        _detailAddress.font = Font_Yuan(13);
        
        _lineLab.backgroundColor = backColor;
        _lineLab.textColor = UIColor.whiteColor;
        
        
        [self addSubviews:@[_lineLab,_detailAddress]];
        [self yuan_LayoutSubViews];
    }
    return self;
}


- (void) yuan_LayoutSubViews {
    
    [_lineLab YuanToSuper_Left:0];
    [_lineLab YuanToSuper_Top:0];
    [_lineLab YuanToSuper_Bottom:0];
    [_lineLab autoSetDimension:ALDimensionWidth toSize:Horizontal(55)];
    
    [_detailAddress YuanMyEdge:Left ToViewEdge:Right ToView:_lineLab inset:0];
    [_detailAddress YuanToSuper_Right:0];
    [_detailAddress YuanToSuper_Top:0];
    [_detailAddress YuanToSuper_Bottom:0];
}


- (void) reloadAddress:(NSString *)address {
    
    
    _detailAddress.text = address;
}






@end
