//
//  Yuan_FL_HeaderView.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/12/1.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_FL_HeaderView.h"

@implementation Yuan_FL_HeaderView
{
    
    UIImageView * _headerIcon;
    
    UILabel * _headerName;
    
    UIView * _line;
    
    UILabel * _resName;
}


#pragma mark - 初始化构造方法

- (instancetype) init {
    
    if (self = [super init]) {
        [self UI_Init];
        self.backgroundColor = UIColor.whiteColor;
    }
    return self;
}


- (void) reloadHeaderName:(NSString *)headerName {
    
    _headerName.text = headerName;
}

- (void) reloadResName:(NSString *)resName {
    
    _resName.text = resName;
}




- (void) UI_Init {
    
    _headerIcon = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"FL_Fiber"]
                                     frame:CGRectNull];
    
    _headerName = [UIView labelWithTitle:@"资源类型" frame:CGRectNull];
    
    _resName = [UIView labelWithTitle:@"资源名称" frame:CGRectNull];
    
    _resName.font = Font_Yuan(13);
    
    
    _line = [UIView viewWithColor:ColorValue_RGB(0xc2c2c2)];
    
    _resName.numberOfLines = 0;//根据最大行数需求来设置
    _resName.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self addSubviews:@[_headerIcon,_headerName,_resName,_line]];
    
    [self yuan_layoutAllSubViews];
}



#pragma mark - 屏幕适配

- (void) yuan_layoutAllSubViews {
    
    float limit = Horizontal(15);
    
    [_headerIcon autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:limit];
    [_headerIcon autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    
    [_headerName YuanAttributeHorizontalToView:_headerIcon];
    [_headerName autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_headerIcon withOffset:limit];
    
    
    
    [_line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_headerIcon withOffset:5];
    [_line autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_line autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_line autoSetDimension:ALDimensionHeight toSize:Vertical(2)];
    
    [_resName autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_line withOffset:5];
    [_resName autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_resName autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    
}



@end
