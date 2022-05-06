//
//  Yuan_OBD_PointsListCell.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_OBD_PointsListCell.h"

@implementation Yuan_OBD_PointsListCell
{
    // 分光器名称
    UILabel * _obd_Name;
    
    // 分光器厂家
    UILabel * _changJ;
    
    // 分光器比例
    UILabel * _bili;
}


#pragma mark - 初始化构造方法

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self UI_Init];
    }
    return self;
}




#pragma mark - UI ---
- (void) UI_Init {
    
    _obd_Name = [UIView labelWithTitle:@"名字" frame:CGRectNull];
    _changJ = [UIView labelWithTitle:@"华为" frame:CGRectNull];
    _bili = [UIView labelWithTitle:@"1:16" frame:CGRectNull];
    
    _changJ.textAlignment = NSTextAlignmentCenter;
    _bili.textAlignment = NSTextAlignmentCenter;
    
    _changJ.backgroundColor = ColorValue_RGB(0xffe7e7);
    _changJ.textColor = ColorValue_RGB(0xfc5f5f);
    
    _bili.backgroundColor = ColorValue_RGB(0xfff3d9);
    _bili.textColor = ColorValue_RGB(0xff9000);
    
    _bili.font = Font_Yuan(12);
    _changJ.font = Font_Yuan(12);
    
    [self.contentView addSubviews:@[_obd_Name,_changJ,_bili]];
    
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(10);
    
    [_obd_Name YuanToSuper_Top:limit];
    [_obd_Name YuanToSuper_Left:limit];
    [_obd_Name YuanToSuper_Right:limit];
    
    [_changJ YuanToSuper_Left:limit];
    [_changJ YuanToSuper_Bottom:limit];
    [_changJ autoSetDimension:ALDimensionHeight toSize:Vertical(15)];
    
    [_bili YuanAttributeHorizontalToView:_changJ];
    [_bili YuanMyEdge:Left ToViewEdge:Right ToView:_changJ inset:limit];
    [_bili autoSetDimensionsToSize:CGSizeMake(Horizontal(35), Vertical(15))];
}

- (void) reloadDict:(NSDictionary *) dict {
    
    // 厂家
    NSString * mfr = dict[@"mfr"] ?: @"";
    
    // 分光比
    NSString * asset = dict[@"asset"] ?: @"";
    
    // 分光器名称
    NSString * resName = dict[@"resName"] ?: @"";
    
    
    _obd_Name.text = resName;
    _changJ.text = mfr;
    _bili.text = asset;
    
}


@end
