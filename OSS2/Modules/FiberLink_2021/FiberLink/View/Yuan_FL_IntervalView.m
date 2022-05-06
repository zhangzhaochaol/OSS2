//
//  Yuan_FL_IntervalView.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/12/1.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_FL_IntervalView.h"

@implementation Yuan_FL_IntervalView

{
    
    UIView * _leftLine;
    
    UILabel * _title;
    
    UIView * _rightLine;
    
    NSString * _myTxt;
    
}



#pragma mark - 初始化构造方法

- (instancetype) initWithTitle:(NSString *)title {
    
    if (self = [super init]) {
        _myTxt = title;
        [self UI_Init];
    }
    return self;
}



#pragma mark -  reload  ---

- (void) reloadTitle:(NSString *)title {
    
    _title.text = title;
}




#pragma mark -  UI  ---


- (void) UI_Init {
    
    _leftLine = [UIView viewWithColor:ColorValue_RGB(0xc2c2c2)];
    _rightLine = [UIView viewWithColor:ColorValue_RGB(0xc2c2c2)];
    
    _title = [UIView labelWithTitle:_myTxt frame:CGRectNull];
    
    [self addSubviews:@[_leftLine,_rightLine,_title]];
    
    [self yuan_layoutAllSubViews];
}


#pragma mark - 屏幕适配

- (void) yuan_layoutAllSubViews {
    
    float limit = Horizontal(15);
    
    [_title YuanAttributeHorizontalToView:self];
    [_title YuanAttributeVerticalToView:self];
    
    [_leftLine autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_leftLine YuanAttributeHorizontalToView:self];
    [_leftLine autoSetDimension:ALDimensionHeight toSize:2];
    [_leftLine autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:_title withOffset:-limit * 3];
    
    
    [_rightLine autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_rightLine YuanAttributeHorizontalToView:self];
    [_rightLine autoSetDimension:ALDimensionHeight toSize:2];
    [_rightLine autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_title withOffset:limit * 3];
    
}

@end
