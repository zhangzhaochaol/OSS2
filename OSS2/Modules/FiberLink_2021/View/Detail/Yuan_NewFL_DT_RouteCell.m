//
//  Yuan_NewFL_DT_RouteCell.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/26.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL_DT_RouteCell.h"

@implementation Yuan_NewFL_DT_RouteCell

{
    UILabel * _num;
    
    UILabel * _device;
    UILabel * _deviceName;
    
    UIView * _backView;
}

#pragma mark - 初始化构造方法

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self UI_Init];
    }
    return self;
}



- (void) cellDict:(NSDictionary *)dict {
    
    _num.text = dict[@"sequence"] ?: @"";
    
    _deviceName.text = dict[@"eptName"] ?: @"";
    
    if ([dict[@"localCreate"] isEqualToString:@"1"]) {
        _deviceName.textColor = UIColor.mainColor;
    }
    else {
        _deviceName.textColor = ColorValue_RGB(0x333333);
    }
}


- (void) UI_Init {
    
    _num = [UIView labelWithTitle:@"1" frame:CGRectNull];
    _num.textAlignment = NSTextAlignmentCenter;
    _num.textColor = UIColor.whiteColor;
    _num.backgroundColor = UIColor.mainColor;
    _num.font = Font_Yuan(13);
    
    _device = [UIView labelWithTitle:@"局向" frame:CGRectNull];
    _device.textColor = UIColor.whiteColor;
    _device.backgroundColor = UIColor.systemPinkColor;
    [_device cornerRadius:3 borderWidth:0 borderColor:nil];
    _device.textAlignment = NSTextAlignmentCenter;
    _device.font = Font_Yuan(12);
    
    _deviceName = [UIView labelWithTitle:@"局向名称" frame:CGRectNull];
    _deviceName.font = Font_Yuan(13);
    _deviceName.numberOfLines = 0;//根据最大行数需求来设置
    _deviceName.lineBreakMode = NSLineBreakByTruncatingTail;
    
    _backView = [UIView viewWithColor:UIColor.whiteColor];
    [_backView cornerRadius:3 borderWidth:1 borderColor:ColorValue_RGB(0xf2f2f2)];
    
    
    [self.contentView addSubview:_backView];
    [_backView addSubviews:@[_num,_device,_deviceName]];

    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    [_backView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(5, 0, 0, 5)];
    
    [_num YuanToSuper_Left:limit];
    [_num YuanAttributeHorizontalToView:_backView];
    [_num autoSetDimensionsToSize:CGSizeMake(20, 20)];
    [_num cornerRadius:10 borderWidth:0 borderColor:nil];
    
    [_device YuanToSuper_Left:Horizontal(50)];
    [_device autoSetDimensionsToSize:CGSizeMake(Horizontal(40), 20)];
    [_device YuanAttributeHorizontalToView:_backView];
    
    [_deviceName YuanMyEdge:Left ToViewEdge:Right ToView:_device inset:limit];
    [_deviceName YuanAttributeHorizontalToView:_device];
    [_deviceName YuanToSuper_Right:limit];
    
}

@end
