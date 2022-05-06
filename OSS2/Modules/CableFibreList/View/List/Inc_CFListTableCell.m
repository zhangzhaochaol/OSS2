//
//  Inc_CFListTableCell.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/20.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_CFListTableCell.h"

@implementation Inc_CFListTableCell
{
    
    
    
    /*上下 图片*/
    UIImageView * _img_Up;
    UIImageView * _img_Down;
    
    //zzc 2021-6-23 光纤性能label
    UILabel *_fiberPerformance;
}


#pragma mark - 初始化构造方法

- (instancetype) initWithStyle:(UITableViewCellStyle)style
               reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _headerLab = [UIView labelWithTitle:@"1" frame:CGRectNull];
        _headerLab.textAlignment = NSTextAlignmentCenter;
        _headerLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:15]; //加粗
        _headerLab.layer.borderColor = [UIColor.lightGrayColor CGColor];
        _headerLab.layer.borderWidth = 1;
        
        _headerLab.backgroundColor = ColorValue_RGB(0xf2f2f2);
        
        
        _titleBusiness = [UIView labelWithTitle:@"业务名称0x0x0x0x0" frame:CGRectNull];
        _titleBusiness.backgroundColor = ColorValue_RGB(0xf2f2f2);
        _titleBusiness.font = Font_Yuan(13);
        
        _titleBusiness.numberOfLines = 0;//根据最大行数需求来设置
        _titleBusiness.lineBreakMode = NSLineBreakByTruncatingTail;
        
        
        _img_Up = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"cf_cheng_shang"]
                                     frame:CGRectMake(0, 0, 20, 20)];
        
        _img_Down = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"cf_cheng_xia"]
                                       frame:CGRectNull];
        
        _fiberPerformance = [UIView labelWithTitle:@"" isZheH:YES];
        _fiberPerformance.textColor = UIColor.whiteColor;
        _fiberPerformance.textAlignment = NSTextAlignmentCenter;
        _fiberPerformance.font = Font_Yuan(11);

        [self.contentView addSubviews:@[_headerLab,
                                        _titleBusiness]];
        
        [self.contentView addSubviews:@[_img_Up,
                                      _img_Down]];
        
        [self.contentView addSubview:_fiberPerformance];
        
        [self layoutAllSubViews];
    }
    return self;
}



/// 左上角图片 是成端还是熔接
- (void) imgConfigUpImage:(CF_HeaderCellType_)upType {
    
    
    _img_Up.hidden = NO;
    if (upType == CF_HeaderCellType_ChengDuan) {
        _img_Up.image = [UIImage Inc_imageNamed:@"cf_cheng_shang"];
    }else if(upType == CF_HeaderCellType_RongJie){
        _img_Up.image = [UIImage Inc_imageNamed:@"cf_rong_shang"];
    }else {

        _img_Up.hidden = YES;
    }
    
}


/// 右下角图片 是成端还是熔接
- (void) imgConfigDownImg:(CF_HeaderCellType_)downType {
    
    
    _img_Down.hidden = NO;

    if (downType == CF_HeaderCellType_ChengDuan) {
        _img_Down.image = [UIImage Inc_imageNamed:@"cf_cheng_xia"];
    }else if(downType == CF_HeaderCellType_RongJie){
        _img_Down.image = [UIImage Inc_imageNamed:@"cf_rong_xia"];
    }else {
        _img_Down.hidden = YES;
    }
    
}


/// 配置文字内容
- (void)configMsg:(NSString *)msg{
    
    NSString * left = @"        ";
    _titleBusiness.text = [left stringByAppendingString:msg];
}


/// 根据 oprStateId 去判断颜色 占用:绿色 故障:红色
/// @param oprStateId id
- (void) configColor:(NSString *)oprStateId  {
    
    
    if (!oprStateId) {
        return;
    }
    
    NSInteger oprstate = [oprStateId integerValue];
    
    switch (oprstate) {
        case 170003:  // 占用
            
            _headerLab.backgroundColor = ColorValue_RGB(0xbbffaa);
            _headerLab.textColor = UIColor.whiteColor;
            break;
        case 170147: // 故障
            
            _headerLab.backgroundColor = ColorR_G_B(246, 100, 109);
            _headerLab.textColor = UIColor.whiteColor;
            break;
            
        default:
            _headerLab.backgroundColor = ColorValue_RGB(0xf2f2f2);
            _headerLab.textColor = UIColor.blackColor;
            break;
    }
    
}

- (void) fiberPerformance:(NSString *) performance  num:(NSString *)num {
    

    
    if ([self isBlankString:performance] && [self isBlankString:num]) {
        _fiberPerformance.backgroundColor = UIColor.lightGrayColor;
        _fiberPerformance.text = [NSString stringWithFormat:@"无"];

    }else{
        if ([[self getOprStateId:performance] isEqualToString:@"优秀"]) {
            _fiberPerformance.backgroundColor = ColorR_G_B(83, 193, 64);
        }else if([[self getOprStateId:performance] isEqualToString:@"一般"]){
            _fiberPerformance.backgroundColor = ColorR_G_B(249, 170, 48);
        }else if([[self getOprStateId:performance] isEqualToString:@"高损耗"]){
            _fiberPerformance.backgroundColor = ColorR_G_B(248, 107, 109);
        }else if([[self getOprStateId:performance] isEqualToString:@"断纤"]){
            _fiberPerformance.backgroundColor = ColorR_G_B(207, 12, 22);
        }else{
            _fiberPerformance.backgroundColor = UIColor.lightGrayColor;
        }
        
        if ([self isBlankString:performance]) {
            performance = @"无";
        }else{
            //performance 从id转name
            performance = [NSString stringWithFormat:@"%@",[self getOprStateId:performance]];
        }
        
        if ([self isBlankString:num]) {
            num = @"";
        }else{
            num = [NSString stringWithFormat:@"\n%@dB",num];
        }
        
//        num = [num stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
    //    _fiberPerformance.text = [NSString stringWithFormat:@"%@\n%@",performance,num];
        _fiberPerformance.text = [NSString stringWithFormat:@"%@%@",performance,num];

    }
    
    
}


// 字符串转换
- (NSString *)getOprStateId:(NSString *)optStr{
    
    NSDictionary *dic =
                      @{@"7021101":@"优秀",
                        @"7021102":@"一般",
                        @"7021103":@"高损耗",
                        @"7021104":@"断纤" };
    return dic[optStr];
    
    
}

-  (BOOL) isBlankString:(NSString *)string {
    
    if (string == nil || string == NULL) {
        
        return YES;
        
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        
        return YES;
        
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        
        return YES;
        
    }
    
    return NO;
}

#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    [_headerLab autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_headerLab autoConstrainAttribute:ALAttributeHorizontal
                           toAttribute:ALAttributeHorizontal
                                ofView:self.contentView
                        withMultiplier:1.0];
    
    [_headerLab autoSetDimensionsToSize:CGSizeMake(Vertical(40), Vertical(40))];

    
    
    [_titleBusiness autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Vertical(45)];
    
    [_titleBusiness autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_headerLab withOffset:Horizontal(5)];
    
    [_titleBusiness autoSetDimension:ALDimensionHeight toSize:Vertical(40)];
    
    [_titleBusiness autoConstrainAttribute:ALAttributeHorizontal
                               toAttribute:ALAttributeHorizontal
                                    ofView:_headerLab
                            withMultiplier:1.0];
    
    
    
    [_img_Up autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_headerLab withOffset:Horizontal(5)];
    
    [_img_Up autoConstrainAttribute:ALAttributeTop toAttribute:ALAttributeTop ofView:_titleBusiness withMultiplier:1.0];
    
    
    [_img_Down autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Vertical(45)];
    
    [_img_Down autoConstrainAttribute:ALAttributeBottom toAttribute:ALAttributeBottom ofView:_titleBusiness withMultiplier:1.0];
    
    [_fiberPerformance autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [_fiberPerformance autoSetDimension:ALDimensionWidth toSize:Vertical(40)];
    [_fiberPerformance autoSetDimension:ALDimensionHeight toSize:Vertical(40)];
    
    [_fiberPerformance autoConstrainAttribute:ALAttributeHorizontal
                               toAttribute:ALAttributeHorizontal
                                    ofView:_headerLab
                            withMultiplier:1.0];

}


@end
