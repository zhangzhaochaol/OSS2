//
//  Yuan_TableViewCell.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/6/28.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_TableViewCell.h"

@implementation Yuan_TableViewCell

{
    UIView * _bgView;
    
    UILabel * _resType;
    UILabel * _resName;
    
    UILabel * _msg;
    UIImageView * _stateImage;
}

#pragma mark - 初始化构造方法

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier    {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self UI_Init];
        self.backgroundColor = UIColor.f2_Color;
    }
    return self;
}




- (void) reloadWithDict:(NSDictionary *)dict {
    
    _resType.text = [Yuan_Foundation fromObject:dict[@"resTypeName"]];
    _resName.text = [Yuan_Foundation fromObject:dict[@"resName"]];
    _msg.text = [Yuan_Foundation fromObject:dict[@"regionName"]];
    
    // 0 不在范围内 1 范围内 2 资源没有管理区域
    NSNumber * isInRange = dict[@"isInRange"];
    NSString * msg = @"";
    NSString * img = @"";
    switch (isInRange.intValue) {
        
        case 0:
            msg = [NSString stringWithFormat:@"维护区域: %@",[Yuan_Foundation fromObject:dict[@"regionName"]]];
            
            img = @"MLD_NoPass";
            break;
            
        case 1:
            msg = [NSString stringWithFormat:@"维护区域: %@",[Yuan_Foundation fromObject:dict[@"regionName"]]];
            
            img = @"MLD_OK";
            break;
            
        case 2:
            msg = @"确实管理区域 , 需要补充管理区域后再删除";
            img = @"MLD_Warning";
            break;
        default:
            break;
    }
    
    _stateImage.image = [UIImage Inc_imageNamed:img];
    _msg.text = msg;
    
    if (isInRange.intValue == 2) {
        _msg.textColor = UIColor.mainColor;
    }
    else {
        _msg.textColor = ColorValue_RGB(0x666666);
    }
}


- (void) UI_Init {
    
    _bgView = [UIView viewWithColor:UIColor.whiteColor];
    [_bgView cornerRadius:10 borderWidth:0 borderColor:nil];
    
    
    _resType = [UIView labelWithTitle:@"资源类型" frame:CGRectNull];
    [_resType cornerRadius:3 borderWidth:0 borderColor:nil];
    _resType.backgroundColor = UIColor.systemPinkColor;
    _resType.textColor = UIColor.whiteColor;
    _resType.font = Font_Yuan(10);
    _resType.textAlignment = NSTextAlignmentCenter;
    
    _resName = [UIView labelWithTitle:@"资源名称" frame:CGRectNull];
    _resName.font = Font_Yuan(12);
    
    _msg = [UIView labelWithTitle:@"资源描述" frame:CGRectNull];
    _msg.font = Font_Yuan(12);
    
    _stateImage = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"MLD_NoPass"]
                                     frame:CGRectNull];
    
    
    [self.contentView addSubview:_bgView];
    [_bgView addSubviews:@[_resType,_resName,_msg,_stateImage]];
    [self yuan_LayoutSubViews];
    
}

- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    [_bgView Yuan_Edges:UIEdgeInsetsMake(limit/2, limit, limit/2, limit)];
    
    [_resType YuanToSuper_Left:limit];
    [_resType YuanToSuper_Top:limit];
    [_resType Yuan_EdgeSize:CGSizeMake(Horizontal(60), Vertical(20))];
    
    [_resName YuanAttributeHorizontalToView:_resType];
    [_resName YuanMyEdge:Left ToViewEdge:Right ToView:_resType inset:limit/2];
    [_resName YuanToSuper_Right:Horizontal(50)];
    
    [_stateImage YuanAttributeHorizontalToView:_resType];
    [_stateImage YuanToSuper_Right:limit/2];
    
    [_msg YuanToSuper_Bottom:limit];
    [_msg YuanToSuper_Right:limit];
    [_msg YuanToSuper_Left:limit];
    
}


@end
