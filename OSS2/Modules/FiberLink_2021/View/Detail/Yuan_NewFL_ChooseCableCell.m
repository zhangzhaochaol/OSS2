//
//  Yuan_NewFL_ChooseCableCell.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL_ChooseCableCell.h"

@implementation Yuan_NewFL_ChooseCableCell

{
    
    UILabel * _deviceName;
    
    UIView * _line;
    
    UILabel * _startDevice;
    UILabel * _startDeviceName;
    
    UILabel * _endDevice;
    UILabel * _endDeviceName;
}


#pragma mark - 初始化构造方法

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self UI_Init];
    }
    return self;
}


- (void) UI_Init {
    
    _deviceName = [UIView labelWithTitle:@"设备名称" frame:CGRectNull];
    _line = [UIView viewWithColor:ColorValue_RGB(0xf2f2f2)];
    
    _startDevice = [UIView labelWithTitle:@"起始设备: " frame:CGRectNull];
    _endDevice = [UIView labelWithTitle:@"终止设备: " frame:CGRectNull];
    
    _startDeviceName = [UIView labelWithTitle:@"设备名称" frame:CGRectNull];
    _endDeviceName = [UIView labelWithTitle:@"设备名称" frame:CGRectNull];
    
    _deviceName.font = _startDevice.font = _endDevice.font = _startDeviceName.font = _endDeviceName.font = Font_Yuan(12);
    
    
    
    [self.contentView addSubviews:@[_deviceName,_line,_startDevice,_startDeviceName,_endDevice,_endDeviceName]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    [_deviceName YuanToSuper_Left:limit];
    [_deviceName YuanToSuper_Top:limit];
    [_deviceName YuanToSuper_Right:limit];
    
    [_line YuanToSuper_Left:limit];
    [_line YuanToSuper_Right:limit];
    [_line YuanMyEdge:Top ToViewEdge:Bottom ToView:_deviceName inset:limit];
    [_line autoSetDimension:ALDimensionHeight toSize:1];
    
    [_startDevice YuanMyEdge:Top ToViewEdge:Bottom ToView:_line inset:limit];
    [_startDevice YuanToSuper_Left:limit];
    [_startDevice autoSetDimension:ALDimensionWidth toSize:Horizontal(70)];
    
    [_startDeviceName YuanAttributeHorizontalToView:_startDevice];
    [_startDeviceName YuanToSuper_Right:limit];
    [_startDeviceName YuanMyEdge:Left ToViewEdge:Right ToView:_startDevice inset:limit];
    
    [_endDevice YuanMyEdge:Top ToViewEdge:Bottom ToView:_startDevice inset:limit];
    [_endDevice YuanToSuper_Left:limit];
    [_endDevice autoSetDimension:ALDimensionWidth toSize:Horizontal(70)];
    
    [_endDeviceName YuanAttributeHorizontalToView:_endDevice];
    [_endDeviceName YuanToSuper_Right:limit];
    [_endDeviceName YuanMyEdge:Left ToViewEdge:Right ToView:_endDevice inset:limit];
    
    
    
}



- (void) reloadCell:(NSDictionary *) dict {
    
    NSString * cableName = dict[@"cableName"];
    NSString * cableStart = dict[@"cableStart"];
    NSString * cableEnd = dict[@"cableEnd"];
    
    _deviceName.text = cableName.length > 20 ? [cableName substringToIndex:19] : cableName;
    _startDeviceName.text = cableStart.length > 20 ? [cableStart substringToIndex:19] : cableStart;
    _endDeviceName.text = cableEnd.length > 20 ? [cableEnd substringToIndex:19] : cableEnd;
}


@end
