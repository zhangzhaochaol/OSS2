//
//  Inc_CFSwitchCell.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/22.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_CFSwitchCell.h"

@implementation Inc_CFSwitchCell

{
    // 编号
    UILabel * _num;
    
    // 名称
    UILabel * _deviceName;
    
}

#pragma mark - 初始化构造方法

- (instancetype) initWithStyle:(UITableViewCellStyle)style
               reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self UI_Config];
        
    }
    return self;
}



- (void) UI_Config {
    
    _num = [UIView labelWithTitle:@"321" frame:CGRectNull];
    _num.textAlignment = NSTextAlignmentCenter;
    _num.font = Font_Yuan(15);
    
    _deviceName = [UIView labelWithTitle:@"xxx设备名称" frame:CGRectNull];
    
    _num.backgroundColor = ColorValue_RGB(0xf2f2f2);
    _num.textColor = Color_V2Red;
    
    _deviceName.numberOfLines = 0;//根据最大行数需求来设置
    _deviceName.lineBreakMode = NSLineBreakByTruncatingTail;
    
    _deviceName.font = Font_Yuan(13);
    _num.font = Font_Bold_Yuan(15);
    
    [self.contentView addSubviews:@[_num,_deviceName]];
    [self layoutAllSubViews];
}


#pragma mark -  赋值  ---

- (void) setCellNum:(NSString *) num
         DeviceName:(NSString *)deviceName {
    
    _num.text = num ?: @"";
    _deviceName.text = deviceName ?: @"";
}



#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    
    [_num autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:Horizontal(5)];
    
    [_num autoConstrainAttribute:ALAttributeHorizontal
                     toAttribute:ALAttributeHorizontal
                          ofView:self.contentView
                  withMultiplier:1.0];
    
    [_num autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [_num autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [_num autoSetDimension:ALDimensionWidth toSize:Horizontal(80)];
    
    
    
    [_deviceName autoPinEdge:ALEdgeLeft
                      toEdge:ALEdgeRight
                      ofView:_num
                  withOffset:Horizontal(5)];
    
    [_deviceName autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(5)];
    
    [_deviceName autoConstrainAttribute:ALAttributeHorizontal
                            toAttribute:ALAttributeHorizontal
                                 ofView:self.contentView
                         withMultiplier:1.0];
    
    
    
}

@end
