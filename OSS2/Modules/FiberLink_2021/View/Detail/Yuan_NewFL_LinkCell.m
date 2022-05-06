//
//  Yuan_NewFL_LinkCell.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL_LinkCell.h"
#import "Yuan_NewFL_VM.h"
@implementation Yuan_NewFL_LinkCell

{
    
    UILabel * _num;
    
    UILabel * _device;
    UILabel * _deviceName;
    
    UILabel * _fiberOrOpt;
    UILabel * _fiberOrOptName;
    
    UIView * _line;
    UIView * _backView;
    
    NSLayoutConstraint * _backView_leftConst;
    NSLayoutConstraint * _backView_rightConst;
    
    Yuan_NewFL_VM * _VM;
}


#pragma mark - 初始化构造方法

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _VM = Yuan_NewFL_VM.shareInstance;
        
        [self UI_Init];
    }
    return self;
}


- (void) cellDict:(NSDictionary *)dict {
    
    if ([dict.allKeys containsObject:belongRouteId]) {
        
        _backView_leftConst.active = _backView_rightConst.active = NO;
        
        _backView_leftConst = [_backView YuanToSuper_Left:Horizontal(15)];
        _backView_rightConst = [_backView YuanToSuper_Right:Horizontal(15)];
    }
    
    else {
        
        _backView_leftConst.active = _backView_rightConst.active = NO;
        
        _backView_leftConst = [_backView YuanToSuper_Left:Horizontal(0)];
        _backView_rightConst = [_backView YuanToSuper_Right:Horizontal(0)];
        
    }
    
    NSString * eptTypeId = dict[@"eptTypeId"];
    
    _num.text = dict[@"sequence"] ?: @"";
    
    // 端子
    if ([eptTypeId isEqualToString:@"317"]) {
        _device.text = @"设备";
        _fiberOrOpt.text = @"端子";
        
        NSString * eptName = dict[@"eptName"] ?: @"";
        _fiberOrOptName.text = eptName;
    }
    // 纤芯
    else {
        _device.text = @"光缆段";
        _fiberOrOpt.text = @"纤芯";
        
        NSString * eptName = dict[@"eptName"] ?: @"";
//        eptName = eptName.length > 25 ? [eptName substringToIndex:24] : eptName;
        
        _fiberOrOptName.text = [NSString stringWithFormat:@"纤芯: %@",eptName];
    }
    
    
    NSString * relateResName = dict[@"relateResName"] ?: @"";
    _deviceName.text = relateResName;
    
}




- (void) reloadRouteData:(NSDictionary *) dict {
    

    NSString * nodeTypeId = dict[@"nodeTypeId"];
    
    _num.text = dict[@"sequence"] ?: @"";
    
    // 端子
    if ([nodeTypeId isEqualToString:@"317"]) {
        _device.text = @"设备";
        _fiberOrOpt.text = @"端子";
        
        NSString * nodeName = dict[@"nodeName"] ?: @"";
        _fiberOrOptName.text = nodeName;
    }
    // 纤芯
    else {
        _device.text = @"光缆段";
        _fiberOrOpt.text = @"纤芯";
        
        NSString * nodeName = dict[@"nodeName"] ?: @"";
//        nodeName = nodeName.length > 25 ? [nodeName substringToIndex:24] : nodeName;
        
        _fiberOrOptName.text = [NSString stringWithFormat:@"纤芯: %@",nodeName];
    }
    
    
    NSString * relateResName = dict[@"rootName"] ?: @"";
    _deviceName.text = relateResName;
    
    
}





- (void) UI_Init {
    
    _num = [UIView labelWithTitle:@"1" frame:CGRectNull];
    _num.textAlignment = NSTextAlignmentCenter;
    _num.textColor = UIColor.whiteColor;
    _num.backgroundColor = UIColor.mainColor;
    _num.font = Font_Yuan(13);
    
    _device = [UIView labelWithTitle:@"设备" frame:CGRectNull];
    _device.textColor = UIColor.whiteColor;
    _device.backgroundColor = UIColor.systemPinkColor;
    [_device cornerRadius:3 borderWidth:0 borderColor:nil];
    _device.textAlignment = NSTextAlignmentCenter;
    _device.font = Font_Yuan(12);
    
    _deviceName = [UIView labelWithTitle:@"设备名称" frame:CGRectNull];
    _deviceName.font = Font_Yuan(13);
    _deviceName.numberOfLines = 0;//根据最大行数需求来设置
    _deviceName.lineBreakMode = NSLineBreakByTruncatingTail;
    
    
    
    
    _fiberOrOpt = [UIView labelWithTitle:@"端子" frame:CGRectNull];
    _fiberOrOpt.textColor = UIColor.whiteColor;
    _fiberOrOpt.backgroundColor = UIColor.darkGrayColor;
    [_fiberOrOpt cornerRadius:3 borderWidth:0 borderColor:nil];
    _fiberOrOpt.textAlignment = NSTextAlignmentCenter;
    _fiberOrOpt.font = Font_Yuan(12);
    
    _fiberOrOptName = [UIView labelWithTitle:@"设备名称" frame:CGRectNull];
    _fiberOrOptName.font = Font_Yuan(13);
    _fiberOrOptName.numberOfLines = 0;//根据最大行数需求来设置
    _fiberOrOptName.lineBreakMode = NSLineBreakByTruncatingTail;
    
    
    _line = [UIView viewWithColor:ColorValue_RGB(0xf2f2f2)];
    
    _backView = [UIView viewWithColor:UIColor.whiteColor];
    [_backView cornerRadius:3 borderWidth:1 borderColor:ColorValue_RGB(0xf2f2f2)];
    
    
    [self.contentView addSubview:_backView];
    
    [_backView addSubviews:@[_num,_device,_deviceName,_line,_fiberOrOpt,_fiberOrOptName]];
    
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    [_backView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(5, 0, 0, 5)];
    
    [_backView YuanToSuper_Top:5];
    [_backView YuanToSuper_Bottom:5];
    _backView_leftConst = [_backView YuanToSuper_Left:0];
    _backView_rightConst = [_backView YuanToSuper_Right:0];
    
    
    [_num YuanToSuper_Left:limit];
    [_num YuanAttributeHorizontalToView:_backView];
    [_num autoSetDimensionsToSize:CGSizeMake(20, 20)];
    [_num cornerRadius:10 borderWidth:0 borderColor:nil];
    
    
    
    [_device YuanToSuper_Left:Horizontal(50)];
    [_device autoSetDimensionsToSize:CGSizeMake(Horizontal(40), 20)];
    [_device autoConstrainAttribute:ALAttributeHorizontal toAttribute:ALAttributeHorizontal ofView:self.contentView withMultiplier:0.6];
    
    [_deviceName YuanMyEdge:Left ToViewEdge:Right ToView:_device inset:limit];
    [_deviceName YuanAttributeHorizontalToView:_device];
    [_deviceName YuanToSuper_Right:limit];
    
    
    [_fiberOrOpt YuanToSuper_Left:Horizontal(50)];
    [_fiberOrOpt autoSetDimensionsToSize:CGSizeMake(Horizontal(40), 20)];
    [_fiberOrOpt autoConstrainAttribute:ALAttributeHorizontal toAttribute:ALAttributeHorizontal ofView:self.contentView withMultiplier:1.4];
    
    [_fiberOrOptName YuanMyEdge:Left ToViewEdge:Right ToView:_fiberOrOpt inset:limit];
    [_fiberOrOptName YuanAttributeHorizontalToView:_fiberOrOpt];
    [_fiberOrOptName YuanToSuper_Right:limit];
    
}


@end
